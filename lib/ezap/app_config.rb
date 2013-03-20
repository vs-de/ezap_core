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
    
    def config_base_file_name
      @config_base_file_name
    end

    #hack to catch the app_root
    def inherited k
      class << k
        attr_accessor :_app_config
      end
      k.app_config_search config_base_file_name
      path = File.expand_path('..', caller.first.split(':').shift)
      while (parent = File.expand_path('..', path)) != path
        break if k.try_config(path)
        path = parent
      end
    end

    def try_config path
      cfg_try0 = File.join(path, 'ezap_adapter.yml')
      cfg_try1 = File.join(path, 'config', config_base_file_name)
      if File.exists?(cfg_try0)
        puts "loading ezap adapter config from #{cfg_try0}..."
        app_config.merge!(YAML.load_file(cfg_try0).symbolize_keys_rec!)
      elsif File.exists?(cfg_try1)
        puts "loading ezap adapter config from #{cfg_try1}..."
        app_config.merge!(YAML.load_file(cfg_try1).symbolize_keys_rec!)
      else
        false
      end
    end

    def app_config
      @_app_config ||= {}
    end
  
  end

  def app_config
    self.class.app_config
  end
end
