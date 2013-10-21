#####
# Copyright 2013, Valentin Schulte
# This file is part of Ezap.
# Ezap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3 
# as published by the Free Software Foundation.
# You should have received a copy of the GNU General Public License
# in the file COPYING along with Ezap. If not, see <http://www.gnu.org/licenses/>.
#####
class Hash

  #just quick implement some handy rails funcs(similar)
  #in place, not recursive
  def symbolize_keys!
    keys.each do |k|
      self[k.to_sym] = self.delete(k)
    end
    self
  end

  #in place recursive
  def symbolize_keys_rec!
    keys.each do |k|
      v = self.delete(k)
      self[k.to_sym] = v.is_a?(Hash) ? v.symbolize_keys_rec! : v
    end
    self
  end

end
