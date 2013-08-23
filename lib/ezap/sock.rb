#####
# Copyright 2013, Valentin Schulte, Leipzig
# This File is part of Ezap.
# It is shared to be part of wecuddle from Lailos Group GmbH, Leipzig.
# Before changing or using this code, you have to accept the Ezap License in the Ezap_LICENSE.txt file 
# included in the package or repository received by obtaining this file.
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

      def ping _sleep=0.1
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
