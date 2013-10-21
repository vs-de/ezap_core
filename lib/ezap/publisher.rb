#####
# Copyright 2013, Valentin Schulte
# This file is part of Ezap.
# Ezap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3 
# as published by the Free Software Foundation.
# You should have received a copy of the GNU General Public License
# in the file COPYING along with Ezap. If not, see <http://www.gnu.org/licenses/>.
#####

module Ezap::Publisher
  def self.included base
    class << base
      attr_accessor :ezap_pub_default_channel
    end
    base.extend ClassMethods
  end

  module ClassMethods
    include Ezap::GlobalMasterConnection
    include Ezap::WrappedZeroExtension
  
    #def publish_on chan #opts
      #opts = {
      #  on: self.class_name
      #}.merge(opts)
      
    #end
    
    #TODO: can be used for additional safety when the number of subscribers is known
    def expects_receivers list
      
    end
    
    #TODO: with own pub socket
    #def broad_cast data, opts
    #  opts = {
    #    channel: (@ezap_pub_default_channel ||= self.class.to_s)
    #  }.merge!(opts)
    #  chan = opts[:channel]
    #  @ezap_pub_socket ||= make_socket :pub
    #end
    
    def raw_broadcast chan, *args
      gm_request :publish, chan, *args
    end
  
    def broadcast *args
      raw_broadcast self.to_s, *args
    end

  end

  def broadcast *args
    self.class.broadcast *args
  end

end
