module Ezap
  module Base

    def self.load_lib arg
      Ezap.load_lib arg
    end

  end

  def self.redis_gem_opts
    cfg = Ezap::Service::GlobalMaster.config(:opts, :cache_storage)
    addr = cfg['addr'].split(':') rescue nil
    unless addr
      $stderr.puts "warning: redis conf not given, falling back to empty conf(/local)" 
      return {}
    end
    {host: addr[0], port: addr[1]}
  end

end
