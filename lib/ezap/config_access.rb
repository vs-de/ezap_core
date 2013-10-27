#####
# Copyright 2013, Valentin Schulte
# This file is part of Ezap.
# Ezap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3 
# as published by the Free Software Foundation.
# You should have received a copy of the GNU General Public License
# in the file COPYING along with Ezap. If not, see <http://www.gnu.org/licenses/>.
#####

module Ezap::ConfigAccess
  
    def method_missing name, *args
      if (m = name.to_s).end_with?('=')
        self.class._hsh[m.chop.to_sym] = args.pop
      else
        raise "config keys take no args" unless args.empty?
        #this double check is important, don't remove the second access-try
        self.class._hsh.has_key?(name) || self.class._hsh[name] || raise("key #{name} is not in config")
        obj = self.class._hsh[name]
        if obj.is_a?(Hash)
          ret = obj[env]
          return ret if ret
          obj.extend CfgHshExt
        end
        obj
      end
    end

    module CfgHshExt

      def [] k
        obj = super k
        if obj.is_a?(Hash)
          ret = obj[Ezap.config.env]
          return ret if ret
          obj.extend CfgHshExt
        end
        obj
      end

      #def []= k, v
      #  self.send k, v
      #end

      def method_missing name, *args
        obj = self[name]
      end
    end

end
