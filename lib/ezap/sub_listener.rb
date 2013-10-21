#####
# Copyright 2013, Valentin Schulte
# This file is part of Ezap.
# Ezap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3 
# as published by the Free Software Foundation.
# You should have received a copy of the GNU General Public License
# in the file COPYING along with Ezap. If not, see <http://www.gnu.org/licenses/>.
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
        respond_to?(sth) && send(sth, *args)
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
