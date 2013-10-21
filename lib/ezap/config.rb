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
    @@hsh = {
      gm_root: EZAP_ROOT
    }

    @@hsh[:config_files] = {File.join(@@hsh[:gm_root], CFG_PATH, CFG_FILE_NAME) => :merge}
    def self._hsh
      @@hsh
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

    def merge_config_file_data path
      @@hsh.merge!(YAML.load_file(path).symbolize_keys_rec!)
    end

    def fill_config_file_data path
      @@hsh.merge!(YAML.load_file(path).symbolize_keys_rec!.merge!(@@hsh))
    end

    def initialize opts={}
      @@hsh[:ezap_env] = (opts[:env] || opts[:ezap_env] || :default).to_sym
      reload
    end

    def env
      @@hsh[:ezap_env]
    end

    def reload
      cfg_files = @@hsh[:config_files]
      rt = @@hsh[:gm_root]
      _env = @@hsh[:ezap_env]
      @@hsh = {config_files: cfg_files, gm_root: rt, ezap_env: _env}
      cfg_files.each {|k,v| self.send("#{v}_config_file_data", k)}
      self
    end

    def to_hash
      @@hsh.clone
    end

  end
end
