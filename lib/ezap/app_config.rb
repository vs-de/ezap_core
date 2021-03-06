#####
# Copyright 2013, Valentin Schulte
# This file is part of Ezap.
# Ezap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3 
# as published by the Free Software Foundation.
# You should have received a copy of the GNU General Public License
# in the file COPYING along with Ezap. If not, see <http://www.gnu.org/licenses/>.
#####

module Ezap::AppConfig

  def self.included base
    base.extend ClassMethods
    class << base
      attr_accessor :config_base_file_name
    end
  end

  @config_base_file_name
  
  module ClassMethods

    def default_app_config_name file_name
      @config_base_file_name = file_name
    end

    def app_config_search file_name
      @config_base_file_name = file_name
    end
    
    #def config_base_file_name
    #  @config_base_file_name
    #end

    #hack to catch the app_root
    def inherited k
      class << k
        attr_accessor :_app_config
      end
      infiltrate k, 2
    end

    
    def infiltrate k , notused=nil
      k.app_config_search config_base_file_name
      cfg_path = search_config Dir.pwd
      return false unless cfg_path
      puts "loading ezap app-config from #{cfg_path}..."
      k.app_config.merge!(YAML.load_file(cfg_path).symbolize_keys_rec!)
    end

    #don't use that, experimental
    def _infiltrate k, n #;)
      #(1..9).each{|n| puts ""+n.to_s+": "+catch_caller_file(n)}
      k.app_config_search config_base_file_name
      cfg_path = search_config catch_caller_file(n)
      return false unless cfg_path
      puts "loading ezap app-config from #{cfg_path}..."
      k.app_config.merge!(YAML.load_file(cfg_path).symbolize_keys_rec!)
    end

    #Warning: that's kind a black magic, use with care
    def catch_caller_file n=1
      File.expand_path('..', caller[n].split(':').shift)
    end

    def search_config path
      while (parent = File.expand_path('..', path)) != path
        p = try_config(path)
        return p if p
        path = parent
      end
    end

    def try_config path
      cfg_try0 = File.join(path, config_base_file_name)
      cfg_try1 = File.join(path, 'config', config_base_file_name)
      return cfg_try0 if File.exists?(cfg_try0)
      return cfg_try1 if File.exists?(cfg_try1)
      false
    end

    def app_config
      @_app_config ||= {}
    end
  
  end

  def app_config
    self.class.app_config
  end
end
