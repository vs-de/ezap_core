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
      sock = make_socket(:req)
      sock.connect(gm_addr)
      #puts "sending gm"
      sock.send_obj(args)
      #puts "receiving gm"
      asw = sock.recv_obj
      sock.close
      asw
    end
   
    #grrr, it doesn't set the socket as readable even if it is
    def gm_ping
      p = ZMQ::Poller.new
      gm_addr = Ezap.config.global_master_address
      sock = make_socket(:req)
      sock.connect(gm_addr)
      p.register(sock)
      p.poll_nonblock
      if p.writables.size == 1
        puts "send OK"
        sock.send_obj(['ping'])
      else
        return 'send: false'
      end
      #p.deregister_writable(p)
      puts "readables: #{p.readables.inspect}"
      puts "writables: #{p.writables.inspect}"
      p2 = ZMQ::Poller.new
      p2.register_readable(sock)
      #p2.poll(1000) #_nonblock #()
      sleep 1
      puts "poll ret: #{p2.poll_nonblock}" #()

      puts "p2 readables: #{p2.readables.inspect}"
      puts "p2 writables: #{p2.writables.inspect}"
      if p2.readables.size == 1
        puts "recv OK"
        asw = sock.recv_obj
      else
        return 'recv: false'
      end
      sock.close
      asw
    end
  end

end
