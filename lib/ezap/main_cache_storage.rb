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
  class MainCacheStorage
    include CacheStorage
  
    attr_reader :type, :addr
    def initialize
      @type = Ezap.config.global_master_service.opts.cache_storage[:type]
      @addr = Ezap.config.global_master_service.opts.cache_storage[:addr]
    end

  end
end
