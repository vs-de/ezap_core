module Ezap::WrappedZeroExtension
  
  def make_socket type, opts={}
    (@sockets ||= []) << (sock = Ezap::Sock.new(type, opts))
    sock
  end

  def close_sockets
    @sockets.each(&:close) if @sockets
  end

end
