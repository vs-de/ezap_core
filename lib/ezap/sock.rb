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
  class Sock #just simple zmq wrapper

    attr_accessor :zs #zmq socket

    def initialize  _type, opts={}
      type = _type.is_a?(Fixnum) ? _type : ZMQ.const_get(_type.to_s.upcase) 
      @zs = Ezap::ZmqCtx().socket(type)
      @zs.extend(InnerSockMethods)
      [:close,  :bind, :recvmsg, :recv_string, :sendmsg, :send_string, :connect, :setsockopt].each do |m|
        define_singleton_method(m) do |*args|
          @zs._raise_error_wrap(m, *args)
        end
      end
      extend OuterSockMethods

    end

    module InnerSockMethods
      #check return value fitting to zmq-ffi gem
      def _raise_error_wrap fname, *args
        ret = __send__(fname, *args)
        unless ZMQ::Util.resultcode_ok?(ret)
          msg = ZMQ::Util.error_string
          raise "#{fname}: returned #{ret}: #{msg}"
        end
        ret
      end
      
    end

    module OuterSockMethods
      def recv fl=0
        str = ''
        recv_string(str, fl)
        str
      end

      def send str, fl=0
        send_string(str, fl)
      end

      def send_obj obj, fl=0
        self.send(MessagePack.pack(obj), fl)
      end

      def recv_obj fl=0
        MessagePack.unpack(self.recv(fl))
      end

      #
      def wait_ping
        
      end

      #strict boolean ping
      def bping
        !!(ping rescue false)
      end

      def ping timeout=5, sleep: 0.01
        p = ZMQ::Poller.new
        p.register(zs)
        ret = send_obj([:ping], ZMQ::NonBlocking)
        #raise?
        #return false unless ZMQ::Util.resultcode_ok?(ret)
        unless ZMQ::Util.resultcode_ok?(ret)
          raise "bad result_code when sending: #{ret}"
        end
        t = Time.now
        while true
          sleep sleep
          p.poll_nonblock
          t1 = Time.now-t
          break if p.readables.size == 1
          if t1 > timeout
            zs.setsockopt(ZMQ::LINGER, 0)
            close
            return false
          end
        end
        asw = ''
        ret = zs.recv_string(asw, ZMQ::NonBlocking)
        unless ZMQ::Util.resultcode_ok?(ret)
          #return false
          raise "bad result_code when receiving: #{ret}"
        end
        return true, MessagePack.unpack(asw), ("%.2f" % t1).to_f

      end
      
      #old version, fixed w8 time
      def _ping _sleep=0.1
        p = ZMQ::Poller.new
        p.register(zs)
        ret = send_obj([:ping], ZMQ::NonBlocking)
        return false unless ZMQ::Util.resultcode_ok?(ret)
        sleep _sleep
        p.poll_nonblock
        unless p.readables.size == 1
          zs.setsockopt(ZMQ::LINGER, 0)
          close
          return false
        end
        asw = ''
        ret = zs.recv_string(asw, ZMQ::NonBlocking)
        unless ZMQ::Util.resultcode_ok?(ret)
          return false
        end
        return true, MessagePack.unpack(asw)
      end
    end

    def close
      @zs.terminate
    end

    #def bind arg
    #  @zs.bind arg
    #end
  end
end
