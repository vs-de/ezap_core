#####
# Copyright 2013, Valentin Schulte
# This file is part of Ezap.
# Ezap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3 
# as published by the Free Software Foundation.
# You should have received a copy of the GNU General Public License
# in the file COPYING along with Ezap. If not, see <http://www.gnu.org/licenses/>.
#####

module Ezap
  class Config

    include Ezap::AppConfig
    include Ezap::ConfigAccess
    
    @@hsh = Hash.new do |h,k|
      if nks = CFG_LINKS.has_key?(k) && CFG_LINKS[k].dup
        val = h
        while nk = nks.shift
          val=val[nk]
        end
        val
      end
    end.merge!(
      gm_root: EZAP_ROOT
    )
    #@@hsh.extend(CfgHshExt)

    #i replace yaml-anchors with this link-hash, because the anchors are hard to write back into a yml and are lost when stored, values are path from root to the linked leave

    CFG_LINKS = {
      global_master_address: [:global_master_service, :sockets, :rep, :addr]
    }
    
    def self.sys_home
      ENV['HOME'].dup
    end

    #key order matters for loading: specific -> global
    CFG_PATHS = Hash.new{|h,k| k if !k.is_a?(Symbol)}.merge(
      local: File.join('.', File.directory?('config') ? 'config' : '', CFG_FILE_NAME),
      home: File.join(sys_home, ".#{CFG_FILE_NAME}"),
      gem: File.join(@@hsh[:gm_root], CFG_PATH, CFG_FILE_NAME),
      default: File.join(@@hsh[:gm_root], CFG_PATH, CFG_DEFAULT_FILE_NAME)
    )

    def self.find_main_config loc
      path = CFG_PATHS[loc.to_sym]
      File.exists?(path) && path
    end

    @init_cfg_file = CFG_PATHS.keys.map{|k|find_main_config k}.find{|x|x}
    @@hsh[:config_files] = {@init_cfg_file => :merge}
    
    #for config_access
    def self._hsh
      @@hsh
    end

    #takes pathname-string or location name when symbol
    def store_init_config loc=:home
      lc = CFG_PATHS[loc]
      #@@hsh[:config_files] ||= {lc => :merge}
      @@hsh[:config_files] = {lc => :merge}
      dump_to loc
    end

    def dump_to loc=:home
      CFG_PATHS[loc].tap &->(p) {dump p}
    end

    def dump fn
      
      f = fn ? open(fn, 'w') : $stdout
      f.write(to_hash.tap(&->(h){h.delete(:config_files)}).stringify_keys_rec!.to_yaml)
      f.close
    end

    def load_init_config fn
      set_source_files({fn => :merge})
      reload
    end

    def set_init_config hsh
      @@hsh[:config_files] = nil
      @@hsh.delete_if{|k| ![:config_files, :ezap_env, :gm_root].include?(k)}
      @@hsh.merge!(hsh.symbolize_keys_rec!)
      @@hsh.extend(CfgHshExt)
    end

    def set_source_files path_hsh
      @@hsh[:config_files] = path_hsh
    end

    def self.search_caller_config name, n=1
      app_config_search name
      search_config catch_caller_file n
    end

    def find_required_file name
      path = self.class.search_caller_config name, 2
      if path
        puts "loading required config: #{path}"
        add_config_file path
      else
        raise "could not find required config: #{name}"
      end
    end

    #type is :merge or :fill
    def add_config_file path, type=:merge
      @@hsh[:config_files].merge!(path => type)
      reload
    rescue Exception => e
      @@hsh[:config_files].delete(path)
      raise e
    end

    def merge_config_data data
      @@hsh.merge!(data.symbolize_keys_rec!)
    end

    def fill_config_data
      @@hsh.merge!(data.symbolize_keys_rec!.merge!(@@hsh))
    end

    def merge_config_file_data path
      merge_config_data YAML.load_file(path)
    end

    def fill_config_file_data path
      fill_config_data YAML.load_file(path)
    end

    def initialize opts={}
      @@hsh[:ezap_env] = (opts[:env] || opts[:ezap_env] || :default).to_sym
      reload
    end

    def env
      @@hsh[:ezap_env].to_sym
    end

    def reload
      files = @@hsh[:config_files]
      @@hsh.delete_if{|k| ![:config_files, :ezap_env, :gm_root].include?(k)}
      files.each {|k,v| self.send("#{v}_config_file_data", k)}
      @@hsh.extend(CfgHshExt)
      self
    end

    def to_hash
      @@hsh.clone
    end

    def to_yaml
      to_hash.stringify_keys_rec!.to_yaml
    end

  end
end
