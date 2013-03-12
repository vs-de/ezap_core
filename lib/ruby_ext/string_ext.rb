class String
  #TODO: change capitalize with sth that only changes the first letter up, not also others down
  #and all other non-alphas should act as sep, too
  unless self.instance_methods.include?(:camelize)
    def camelize
      self.split('_').map(&:capitalize).join
    end
  end
end
