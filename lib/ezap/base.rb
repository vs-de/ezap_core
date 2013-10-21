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
