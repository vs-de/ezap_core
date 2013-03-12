#####
# Copyright 2013, Valentin Schulte, Leipzig
# This File is part of Ezap.
# It is shared to be part of wecuddle from Lailos Group GmbH, Leipzig.
# Before changing or using this code, you have to accept the Ezap License in the Ezap_LICENSE.txt file 
# included in the package or repository received by obtaining this file.
#####

class Ezap::SubscriptionListener
  include Ezap::Base
  include Ezap::GlobalMasterConnection
  include Ezap::WrappedZeroExtension

  attr_accessor :threads
  def  initialize config={}#scope, addr, config={}
    @handler_class = config[:handler] || EventHandler
    #subscribe scope, addr
    #start scope, addr
    @threads = []
  end

  def subscribe scope, addr
    @sock.setsockopt(ZMQ::SUBSCRIBE, scope)
    @sock.connect(addr)
  end

  def gm_pub_addr
    asw = gm_request(:gm_pub_addr)
    addr = asw['address']
    #puts "gm pub addr: #{addr.inspect}"
    raise "asw: #{asw.inspect}" unless addr
    addr
  end

  #TODO: context creation not needed, just socket must be thread-owned
  def start scope, addr=nil
    @threads << Thread.new do
      sock = make_socket(:sub)
      #subscribe scope, addr
      sock.setsockopt(ZMQ::SUBSCRIBE, scope)
      sock.connect(addr || gm_pub_addr)
      puts "listening on #{sock}:"
      while true do
        raw_event = sock.recv
        arr = MessagePack.load(raw_event[(raw_event.index('|').succ..-1)])
        #eh = EventHandler.new(obj)
        first = arr.shift
        break if first == 'stop'
        eh = @handler_class.new(first, *arr)
      end
      sock.close
    end
  end

  def recv
    #@sock.recv
  end

  def fall_back_handler
  
  end

  def stop
    #@sock.close
  end

  def join
    @threads.each(&:join)
  end
  def wait;join;end

  class EventHandler
    attr_reader :value
    def initialize sth, *args
      if sth.is_a?(String) || sth.is_a?(Symbol)
        send(sth, *args)
      else
        @obj = sth
      end
    end

    def process!
      puts "working on #{@obj.inspect}"
      @value = false
    end

  end

end
