
module Ezap::AppConfig

  def  self.included base
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
      k.app_config_search config_base_file_name
      cfg_path = search_config catch_caller_file
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
