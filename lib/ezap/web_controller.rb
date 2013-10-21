#####
# Copyright 2013, Valentin Schulte
# This file is part of Ezap.
# Ezap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3 
# as published by the Free Software Foundation.
# You should have received a copy of the GNU General Public License
# in the file COPYING along with Ezap. If not, see <http://www.gnu.org/licenses/>.
#####
class Ezap::WebController

  #don't take this approach too serious...
  def self.config
    Ezap.config
  end
  $: << File.join(config.root, 'external', 'innate', 'lib')
  require "innate"

  include Innate::Node

  #def self.included base

  #end

  def config
    self.class.config
  end

  def start
    #Innate.start(started: true, root: config.root)
  end

  def start!
    #Innate.start(root: config.root)
    #Innate.start(adapter: :webrick)
    Innate.start(adapter: :mizuno)
  end

  def host
    request.env['HTTP_HOST']
  end

end

