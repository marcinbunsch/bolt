class Array

  # invoke a method on each element of the array and return an array of return values
  def invoke(method_name, *args, &block)
    self.collect { |item| item.send(method_name.to_sym, *args, &block) }
  end
  
end