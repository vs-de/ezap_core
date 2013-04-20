module Ezap
  class MainCacheStorage
    include CacheStorage
  
    attr_reader :type, :addr
    def initialize
      @type = Ezap.config.global_master_service.opts.cache_storage[:type]
      @addr = Ezap.config.global_master_service.opts.cache_storage[:addr]
    end

  end
end
