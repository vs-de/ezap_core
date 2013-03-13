module Ezap
  #TODO: this is crap now, maybe rebuild from scratch
  class Config
    @@hsh = {
      root: EZAP_ROOT
    }
    @@hsh[:config_file] = File.join(@@hsh[:root], CFG_PATH, CFG_FILE_NAME)
    #@@hsh.merge!(YAML.load_file(@@hsh[:config_file]).symbolize_keys_rec!)
    
    def initialize
      reload
    end

    def reload
      cfg = @@hsh[:config_file]
      rt = @@hsh[:root]
      @@hsh = {config_file: cfg, root: rt}
      @@hsh.merge!(YAML.load_file(@@hsh[:config_file]).symbolize_keys_rec!)
    end
    
    def method_missing name, *args
      if (m = name.to_s).end_with?('=')
        @@hsh[m.chop.to_sym] = args.pop
      else
        raise "config keys take no args" unless args.empty?
        @@hsh[name] || raise("key #{name} is not in config")
      end
    end

    def to_hash
      @@hsh.clone
    end
  end
end
