#####
# Copyright 2013, Valentin Schulte
# This file is part of Ezap.
# Ezap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3 
# as published by the Free Software Foundation.
# You should have received a copy of the GNU General Public License
# in the file COPYING along with Ezap. If not, see <http://www.gnu.org/licenses/>.
#####

class Ezap::Service::GlobalMaster < Ezap::Service::Master

  #PUB_CHANNELS = Hash.new{|h,k|"/gms/#{k}"}.merge({}
    #main: '/gms/main/'
    #debug: 'gms/log/debug'
    #oob: = '/oob/'
  #)

  def initialize
    raise "global master cannot have an instance!"
  end

  class <<self
    attr_accessor :state, :services, :bad_services
  end

  PID_FILE = File.join(Ezap.config.gm_root, 'var', 'pids', 'global_master.pid')
  LOG_FILE = File.join(Ezap.config.gm_root, 'log', 'global_master.log')

  #TODO: 
  #     1) use a logger object
  #     2) use cache-system
  #service identifier:
  #type/id/
  #should sign off

  #we use ||= and not = here to allow re-reading the source file
  @services ||= {}
  @bad_services ||= {}
  
  #States: 
  # -running
  # -stopped

  @config ||= Ezap.config.global_master_service
  @state ||= :stopped
  #@log_file
  #@opts
  @cache_store ||= Ezap::MainCacheStorage.new

  #@local_prefix = 'lc'


  #####                                                          #####
  ##                                                                ##
  #  LocalMethods - accessed from dispatcher on running GM-instance  #
  ##                                                                ##
  #####                                                          #####

  # every method defined here will later be made available automatically
  # as static method over remote but will executed locally on the running 
  # instance(hence the name)

  module LocalMethods

    #### init ####
    
    @names = []
    class << self
      attr :names
    end
    def self.method_added m
      unless m.to_s =~ /^local_/
        @names << m
        alias_method "local_#{m}", m
        remove_method m
      end
    end 

    #### here we go ####
   
    def load_main_config new_cfg
      Ezap.config.set_init_config new_cfg
      @config = Ezap.config.global_master_service
    end

    def store_main_config loc=:home
      Ezap.config.store_init_config loc.to_sym
    end
    
    def store_main_config_to path
      Ezap.config.store_init_config path
    end

    def config *args
      args.inject(Ezap.config.global_master_service){|cfg,msg| cfg.send(msg)}
    end

    def reload_source
      src = File.expand_path(__FILE__)
      puts "reloading from #{src}"
      load src
      true
    end

    def reload_config
      @config = Ezap.config.reload.global_master_service
      true
    end
    
    def service_info
      services.map{|name, s| {name => [s.address, s.remote_address]} if s}.compact
    end
    
    def bad_service_info
      bad_services.map{|name, list| {name => list.map(&:address)} if list}.compact
    end

    def hostname
      Socket.gethostname
    end

    def zmq_version
      ZMQ::Util.version
    end

    def zmq_version_string
      local_zmq_version.map(&:to_i).join('.')
    end
    
  end
  
  #here we make all these local methods available as public & remote static methods on GM 
  module RemoteMethods
    #[:load_main_config_file]
    LocalMethods.names.each do |m|
      define_method(m) {|*args| gm_request(m, *args)}
    end
  end
  
  #####                                 #####
  ##                                       ##
  #  ClassMethods - non-automapped methods  #
  ##                                       ##
  #####                                 #####

  module ClassMethods
    include Ezap::WrappedZeroExtension
    include Ezap::GlobalMasterConnection
    include LocalMethods
    include RemoteMethods

    def daemonize
      #warning?
      #raise "Error: pidfile already exists!"
      if File.exists?(PID_FILE)
        f = File.open(PID_FILE, 'r')
        $stderr.puts "warning: old pid file exists with pid #{f.read}. Deleting..."
        f.close
        File.delete(PID_FILE)
      end
      Process.daemon
      #that fixes the zmq usage before pid-change
      Ezap::ZmqCtx.reset
      f = File.open(PID_FILE, 'w');f.write(Process.pid);f.close
      start_log
    end

    def start opts={}
      if gm_ping 2
        $stderr.puts "warning: ezap gm seems to be up already. Start canceled."
        return false
      end
      (@opts ||= {:daemonize => true}).merge!(opts.symbolize_keys!)
      puts "ezap global master starting..."
      daemonize if @opts[:daemonize]
      super
    end

    def close_log
      @log_file && @log_file.close
    end

    def start_log
      @log_file = File.open(LOG_FILE, 'a')
      $stdout = $stderr = @log_file
    end

    def state!(st)
      @state = st.to_sym
    end

    #TODO: should be working over network like shutdown is
    def running?
      @state == :running
    end

    def loop_rep
      #exit_state = false
      puts "GM starting loop rep" if running?
      while running? do
        loop_rep_body
      end
    end

    def loop_rep_body
      #puts "start inner loop_rep"
      req = @rep.recv_obj
      disp = dispatch_request(req)
      print "|sending...";$stdout.flush
      @rep.send_obj(disp.key?(:reply) ? disp[:reply] : disp)
      puts "sent"
      hook = [disp[:after_response]].flatten.compact
      !hook.empty? && send(*hook)
    rescue MessagePack::MalformedFormatError => e
      $stderr.puts "Error: could not decode request: #{e.message}";$stderr.flush
      @rep.send_string('rst')
    #rescue => e
    #  state!(:failure)
    #  raise "GM Fatal: #{e.message} #{e.inspect}"
    end

    def dispatch_request req
      return {error: "wrong request data format"} unless req.is_a?(Array)
      cmd = req.shift
      print "recvd:#{cmd}|"
      GmDispatcher.send(cmd, *req) 
    rescue Exception => e
      {error: e.message}
    end

    def service_count
      @services.values.map(&:size).sum
    end

    #sends to running instance
    #TODO:
    #maybe should all be initialized when class is used, see start
    def shutdown
      if gm_ping to=2
        asw = gm_request :shutdown
        puts "stop asw: #{asw} "
        true
      else
        puts "could not connect to gm within #{to}s."
        false
      end
    end
    
    #closes and re-opens sockets and eventually log(if daemonized)
    def soft_reset pause=1
      gm_request :soft_reset
    end

    def local_soft_reset pause=1
      state!(:restarting)
      puts "restarting GM..."
      close_sockets
      puts "sockets closed."
      if @opts[:daemonize]
        close_log
        start_log
      end
      sleep pause
      start(daemonize: false)
    end


    #TODO: this is a bit unclear
    #def send_public channel, obj
    #  chan = PUB_CHANNELS[channel]
    #  puts "GM: send pub: #{chan}"
    #  @pub.send(chan+MessagePack.pack(obj))
    #end

    def publish chan, cmd, *args
      puts "PUB send: #{chan}|#{cmd} #{args.inspect}"
      @pub.send(chan+'|'+MessagePack.pack([cmd]+args))
    end

    #TODO shutdown all known services
    def local_shutdown_system
      #@pub.send()
    end

    #TODO: should this still be offered at all?
=begin
    def assign_service_port rs
      range = @config[:opts][:sub_port_range] rescue nil
      raise "no port range defined but requested" unless range
      @assigned_ports ||= []
      min = range[:start]
      max = range[:end]
      cur = min
      while @assigned_ports.include?(cur);cur+=1;end
      raise "port range exceeded" if cur > max
      @assigned_ports << cur
      rs.set_port(cur)
    end
=end
    def stop
      state!(:stopped)
      puts "stopping GM."
      close_sockets
      puts "sockets closed."
      close_log
      File.delete(PID_FILE) if File.exists?(PID_FILE)
    end

    def ping *args
      gm_ping *args
    end

    def locate_service name
      gm_request :locate_service, name
    end

    #wait for availability
    def wait
      wait_for_gm
    end
    
    def auto_ip_listen srv
      client = srv.accept
      client.write(client.remote_address.ip_address)
      client.close
      srv.close
    end
    
  end

  extend ClassMethods

  ###                ###
  #     Dispatcher     #
  ###                ###

  class GmDispatcher
    module Commands
      GM = Ezap::Service::GlobalMaster

      Ezap::Service::GlobalMaster::LocalMethods.names.each do |m|
        define_method(m) {|*args| {reply: GM.send("local_#{m}", *args)}}
      end

      def shutdown
        {reply: 'ack', after_response: 'stop'}
      end
      
      def soft_reset
        {reply: 'ack', after_response: 'local_soft_reset'}
      end

      def state
        {reply: GM.state}
      end

      #y, this is not zmq style, but i want to allow
      #a useful "as-seen-by gm" auto-ip config on every service
      #but this should at least never be hard-coded, should stay optional

      def auto_ip
        srv = TCPServer.new('0.0.0.0', 0)
        {reply: srv.addr[1], after_response: [:auto_ip_listen, srv]}
      end

      def svc_reg opts
        opts.symbolize_keys_rec!
        name = opts[:name]
        unless name
          return {error: "service requires at least a name"}
        end
        if (rs = GM.services[name])
          if rs.healthy?
            return {error: "service with name '#{name}' already registered and healthy"}
          else
            print 're- ' #;)
            (GM.bad_services[name] ||= []) << GM.services.delete(name)
          end
        end
        print "adding service: #{name}"
        new_rs = RemoteService.new(opts)
        GM.services[name] = new_rs
        {reply: {service_number: GM.services.keys.size, address: new_rs.remote_address}}
      end

      def svc_unreg name
        puts "removing service: #{name}"
        GM.services[name] = nil
        {reply: :ack}
      end

      def locate_service name
        print "addr request for #{name.inspect}"
        #puts "services: #{GM.services.inspect}"
        rs = GM.services[name]
        return {reply: {}} unless rs
        {reply: {address: rs.address}}
      end

      def gm_pub_addr
        {reply: {address: GM.get_addr_of(:pub)}}
      end

      def ping
        {reply: 'ack'}
      end
      
      #TODO: see GM.send_public
      #def send_public obj
      #  GM.send_public("services", obj)
      #  {reply: 'ack'}
      #end

      def publish chan, *args
        GM.publish chan, *args
        {reply: :ack}
      end

    end
    extend Commands
    def self.commands
      {reply: Commands.public_instance_methods}
    end
  end

  #remote as seen from globalmaster
  #TODO: that's just very roughly hacked here
  class RemoteService
    GM = Ezap::Service::GlobalMaster
    #remote address is address seen from service-adapter
    attr_accessor :address, :properties, :remote_address

    def initialize opts
      @properties = opts
      @proto = opts[:proto] || 'tcp'
      #if @host = opts[:host]
      #  GM.assign_service_port(self)
      #end
      @address = opts[:address]
      @remote_address = opts[:remote_address] || @address
    end

    #TODO: fill
    def healthy?
      ping
    end

    def ping
      sock = Ezap::Sock.new(:req)
      sock.connect self.address
      sock.ping
    end

    #TODO: probably wrong for other transports
    #def rebuild_address
    #  @address = "#{@proto}://#{@host}:#{@port}"
    #end

    #def set_port p
    #  @port = p
    #  rebuild_address
    #end
  end

end
