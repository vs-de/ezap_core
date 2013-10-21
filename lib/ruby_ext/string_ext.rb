#####
# Copyright 2013, Valentin Schulte
# This file is part of Ezap.
# Ezap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3 
# as published by the Free Software Foundation.
# You should have received a copy of the GNU General Public License
# in the file COPYING along with Ezap. If not, see <http://www.gnu.org/licenses/>.
#####
class String
  #TODO: change capitalize with sth that only changes the first letter up, not also others down
  #and all other non-alphas should act as sep, too
  unless self.instance_methods.include?(:camelize)
    def camelize
      self.split('_').map(&:capitalize).join
    end
  end
end
