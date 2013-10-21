#####
# Copyright 2013, Valentin Schulte
# This file is part of Ezap.
# Ezap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3 
# as published by the Free Software Foundation.
# You should have received a copy of the GNU General Public License
# in the file COPYING along with Ezap. If not, see <http://www.gnu.org/licenses/>.
#####
class Ezap::ZmqCtx
  def self.get
    @ctx ||= ZMQ::Context.new
  end

  #reset zmq context, normaly not needed
  def self.reset
    @ctx = ZMQ::Context.new
  end
  
  def self.close
    unless @ctx
      $stderr.puts "warn: no context to close"
    else
      @ctx.terminate
    end
  end

end
def Ezap::ZmqCtx
  Ezap::ZmqCtx.get
end
   
