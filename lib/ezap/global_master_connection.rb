#####
# Copyright 2013, Valentin Schulte, Leipzig
# This File is part of Ezap.
# It is shared to be part of wecuddle from Lailos Group GmbH, Leipzig.
# Before changing or using this code, you have to accept the Ezap License in the Ezap_LICENSE.txt file 
# included in the package or repository received by obtaining this file.
#####

module Ezap

=begin
  unless self.methods.include?(:config)
    Ezap.instance_eval do
      def config
        o = Object.new
        def o.global_master_address
          'tcp://127.0.0.1:43691'
        end
        o
      end
    end
  end
=end

  module GlobalMasterConnection
    
    def gm_request *args
      gm_addr = Ezap.config.global_master_address
      @__gm_sock ||= make_socket(:req)
      @__gm_sock.connect(gm_addr)
      #puts "sending gm"
      @__gm_sock.send_obj(args)
      #puts "receiving gm"
      asw = @__gm_sock.recv_obj
      asw
    end

    def gm_close
      @__gm_sock && @__gm_sock.close
    end


    def obj_req_ping addr, _sleep=0.01
      
    end

    def verbose_obj_req_ping addr, _sleep=0.01
      counter = 0
      sock = make_socket(:req)
      sock.connect(addr)
      p = ZMQ::Poller.new
      p.register(sock.zs)
      #possibly unnecessary
=begin
      p.poll_nonblock
      unless p.writables.size == 1
        puts "no writable after poll"
        return false
      end
=end
      ret = sock.send_obj([:ping], ZMQ::NonBlocking)
      unless ZMQ::Util.resultcode_ok?(ret)
        puts "send ret: #{ret}"
        puts ZMQ::Util.error_string
      end
      sleep _sleep
      p.poll_nonblock
      unless p.readables.size == 1
        puts "no readables after poll"
        sock.setsockopt(ZMQ::LINGER, 0)
        sock.close
        return false
      end
      asw = ''
      ret = sock.zs.recv_string(asw, ZMQ::NonBlocking)
      unless ZMQ::Util.resultcode_ok?(ret)
        puts "recv ret: #{ret}"
        puts ZMQ::Util.error_string
      end
      return counter, asw
    end
  
    def verbose_gm_ping
      verbose_obj_req_ping Ezap.config.global_master_address
    end

    def gm_ping *args
      sock = make_socket(:req)
      sock.connect(Ezap.config.global_master_address)
      ret = sock.ping(*args)
      sock.close
      ret
    end

    #wait for gm to appear...
    def wait_for_gm timeout=1*60*60, poll_ivl=1
      t = Time.now
      until gm_ping 10
        return false if Time.now - t > timeout
        sleep poll_ivl
      end
      true
    end
#doesn't work as expected in case of rep down
#see zmq doc
=begin
    def obj_req_ping addr
      counter = -2
      p = ZMQ::Poller.new
      sock = make_socket(:req)
      sock.connect(addr)
      p.register(sock.zs)
      p.poll_nonblock
      puts p.writables.inspect
      puts p.readables.inspect
      if p.writables.size == 1
        counter += 1
        puts "sending..."
        sock.send_obj([:ping])
        sleep 0.1
        puts "poll 2"
        p.poll_nonblock
        if p.readables.size == 1
          asw = sock.recv_obj
          counter += 1
        end
      end
      return counter, asw
    end
  
    def gm_ping
      obj_req_ping Ezap.config.global_master_address
    end
=end
  end

end
