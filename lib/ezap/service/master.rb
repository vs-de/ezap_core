#####
# Copyright 2013, Valentin Schulte
# This file is part of Ezap.
# Ezap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3 
# as published by the Free Software Foundation.
# You should have received a copy of the GNU General Public License
# in the file COPYING along with Ezap. If not, see <http://www.gnu.org/licenses/>.
#####
class Ezap::Service::Master
  include Ezap::Base
  include Ezap::GlobalMasterConnection
  include Ezap::WrappedZeroExtension

  module ClassMethods

    def start opts={}
      @pub = make_socket(:pub)
      @rep = make_socket(:rep)
      @req = make_socket(:req)
      bind :rep
      bind :pub
      state!(:running)
      loop_rep
    end
   
    #1 sock per type looks a bit poor, but probably sufficiant for a master
    def bind type
      addr = get_addr_of type
      puts "bind #{type} addr: #{addr}"
      instance_variable_get("@#{type}").bind(addr)
    end
    
    def get_addr_of sock_type
      @config[:sockets][sock_type.to_sym][:addr]
    end

  end

  extend ClassMethods
  #def initialize cfg
  #  self.config= cfg
  #end
  #

end
