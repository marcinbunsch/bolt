require 'spec'
require File.dirname(__FILE__) + '/../../../../lib/bolt/ext/core/array'

class FooTestClass

  def test_method
    1
  end
  
  def test_method_with_one_arg(arg1)  
    arg1
  end
  
  def test_method_with_two_args(arg1, arg2)  
    [arg1, arg2]
  end
  
  def test_method_with_a_block  
    yield(self)
  end
  
  def test_method_with_one_arg_and_a_block(arg1)  
    [arg1, yield(self)]
  end
  
  def test_method_with_two_args_and_a_block(arg1, arg2)
    [arg1, arg2, yield(self)]
  end
  
end

describe Array do
  
  it 'should call method for each element of the array' do
    results = [FooTestClass.new, FooTestClass.new, FooTestClass.new].invoke :test_method
    results.should == [1, 1, 1]
  end
  
  it 'should call method with one argument for each element of the array' do
    results = [FooTestClass.new, FooTestClass.new, FooTestClass.new].invoke :test_method_with_one_arg, 2
    results.should == [2, 2, 2]
  end
  
  it 'should call method with one argument as a hash for each element of the array' do
    results = [FooTestClass.new, FooTestClass.new, FooTestClass.new].invoke(:test_method_with_one_arg, :foo => 1, :boo => 2)
    results.first.class.should == Hash
    results.first.keys.should include(:foo)
    results.first.keys.should include(:boo)
    results.first[:foo].should == 1
    results.first[:boo].should == 2
    results.first.should == results[1]
    results.first.should == results[2]
  end
  
  it 'should call method with two arguments for each element of the array' do
    results = [FooTestClass.new, FooTestClass.new, FooTestClass.new].invoke :test_method_with_two_args, 2, 3
    results.should == [[2, 3], [2, 3], [2, 3]]
  end
  
  it 'should call method with two arguments and one as a hash for each element of the array' do
    results = [FooTestClass.new, FooTestClass.new, FooTestClass.new].invoke(:test_method_with_two_args, 1, :foo => 1, :boo => 2, :goo => 3)
    results.first.last.class.should == Hash
    results.first.last.keys.should include(:foo)
    results.first.last.keys.should include(:boo)
    results.first.last.keys.should include(:goo)
    results.first.last[:foo].should == 1
    results.first.last[:boo].should == 2
    results.first.last[:goo].should == 3
    results.first.should == results[1]
    results.first.should == results[2]
  end
  
  it 'should call method with a block for each element of the array' do
    results = [FooTestClass.new, FooTestClass.new, FooTestClass.new].invoke(:test_method_with_a_block) { |item| [4, item.class] }
    results.should == [[4, FooTestClass], [4, FooTestClass], [4, FooTestClass]]
  end
  
  it 'should call method with a block and one arg for each element of the array' do
    results = [FooTestClass.new, FooTestClass.new, FooTestClass.new].invoke(:test_method_with_one_arg_and_a_block, 3) { |item| [4, item.class] }
    results.should == [[3, [4, FooTestClass]], [3, [4, FooTestClass]], [3, [4, FooTestClass]]]
  end
  
  it 'should call method with a block and one arg for each element of the array' do
    results = [FooTestClass.new, FooTestClass.new, FooTestClass.new].invoke(:test_method_with_two_args_and_a_block, 3, 5) { |item| [4, item.class] }
    results.should == [[3, 5, [4, FooTestClass]], [3, 5, [4, FooTestClass]], [3, 5, [4, FooTestClass]]]
  end
  
end