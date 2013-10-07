class Object
  # List methods which aren't in superclass
  def local_methods
    if [Class, Module].include? self.class
      self.methods - self.superclass.methods
    else
      self.methods - self.class.superclass.instance_methods
    end.sort
  end

  def pure_local_methods
    if [Class, Module].include? self.class
      self.methods - (self.ancestors - [self]).map(&:methods).flatten
    else
      self.methods - (self.class.ancestors - [self.class]).map(&:instance_methods).flatten
    end.sort
  end

  # print documentation
  # ri 'Array#pop'
  # Array.ri
  # Array.ri :pop
  # arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    system 'ri', method.to_s
  end
end
