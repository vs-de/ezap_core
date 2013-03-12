#####
# Copyright 2013, Valentin Schulte, Leipzig
# This File is part of Ezap.
# It is shared to be part of wecuddle from Lailos Group GmbH, Leipzig.
# Before changing or using this code, you have to accept the Ezap License in the Ezap_LICENSE.txt file 
# included in the package or repository received by obtaining this file.
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
