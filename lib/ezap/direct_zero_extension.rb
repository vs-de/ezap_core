#####
# Copyright 2013, Valentin Schulte
# This file is part of Ezap.
# Ezap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3 
# as published by the Free Software Foundation.
# You should have received a copy of the GNU General Public License
# in the file COPYING along with Ezap. If not, see <http://www.gnu.org/licenses/>.
#####
module Ezap::DirectZeroExtension
  def make_socket type
    type = ZMQ.const_get(type.to_s.upcase) unless type.is_a? Fixnum
    (@socks ||= []) << (sock = Ezap::ZmqCtx().socket(type))
    sock
  end

  def zmq_stop
    @socks.each(&:close) if @socks
    Ezap::ZmqCtx.close
  end
end
