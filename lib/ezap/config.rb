#####
# Copyright 2013, Valentin Schulte, Leipzig
# This File is part of Ezap.
# It is shared to be part of wecuddle from Lailos Group GmbH, Leipzig.
# Before changing or using this code, you have to accept the Ezap License in the Ezap_LICENSE.txt file 
# included in the package or repository received by obtaining this file.
#####

module Ezap
  class Config

    include Ezap::AppConfig
    @@hsh = {
      gm_root: EZAP_ROOT
    }

    @@hsh[:config_files] = {File.join(@@hsh[:gm_root], CFG_PATH, CFG_FILE_NAME) => :merge}
   
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

    def initialize
      reload
    end

    def reload
      cfg_files = @@hsh[:config_files]
      rt = @@hsh[:gm_root]
      @@hsh = {config_files: cfg_files, gm_root: rt}
      cfg_files.each {|k,v| self.send("#{v}_config_file_data", k)}
      self
    end
    
    def method_missing name, *args
      if (m = name.to_s).end_with?('=')
        @@hsh[m.chop.to_sym] = args.pop
      else
        raise "config keys take no args" unless args.empty?
        @@hsh.has_key?(name) || raise("key #{name} is not in config")
        @@hsh[name]
      end
    end

    def to_hash
      @@hsh.clone
    end

  end
end
