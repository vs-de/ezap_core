
module Ezap::ConfigAccess
  
    def method_missing name, *args
      if (m = name.to_s).end_with?('=')
        self.class._hsh[m.chop.to_sym] = args.pop
      else
        raise "config keys take no args" unless args.empty?
        self.class._hsh.has_key?(name) || raise("key #{name} is not in config")
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
