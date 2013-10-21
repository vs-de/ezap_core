#####
# Copyright 2013, Valentin Schulte
# This file is part of Ezap.
# Ezap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3 
# as published by the Free Software Foundation.
# You should have received a copy of the GNU General Public License
# in the file COPYING along with Ezap. If not, see <http://www.gnu.org/licenses/>.
#####
class SimpleLogCore
  
  def initialize ret
    @buffer = ''
    @ret = ret
  end

  def write arg
    @buffer << arg
  end

  def close
    @ret.log_ready(self) if @ret.respond_to?(:log_ready)
  end

  def read
    @buffer
  end
end

class WorkLoggerScheme
  attr_reader :log_object

  def initialize obj, _tree={}, indent='' # &recv_block
    @indent = indent
    @log_object = obj.is_a?(LogObject) ? obj : LogObject.new(obj)
    @tree = _tree
    #super(@log_object)
  end

  #def log lvl, msg, name, &blk
  #  "log_called #{super(lvl, msg, name) &blk}"
  #end

  def processing obj
    handle_transitions = obj.respond_to?(:status)
    info "processing #{obj.class} #{obj.id}"
    key = "#{obj.class.to_s.underscore}_#{obj.id}".to_sym
    hsh = (@tree[key] ||= {})
    next_log = self.class.new(@log_object, hsh, @indent+'->')
    if handle_transitions
      init_state = obj.status
      yield next_log
      final_state = obj.status
      (hsh[:transitions] ||= {}).merge!(init_state => final_state)
    else
      yield next_log
    end
  end

  def transition sub, cmd
    transisions = (@tree[:transitions] ||= {})
  end

  def close
    @tree
  end

end

class WorkLogger
  DEFAULT_LEVELS = [:debug, :info, :warn, :error, :fatal]
  def initialize obj, levels = DEFAULT_LEVELS
    levels.each do |lvl|
      define_singleton_method(lvl) do |arg|
        obj.write(obj, arg)
      end
    end
  end
end


