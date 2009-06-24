require 'spec'
require File.dirname(__FILE__) + '/../lib/bolt'

describe Bolt do

  it 'should load .bolt file and access config' do
    File.stub(:exists?).and_return(true)
    YAML.stub(:load_file).and_return({ 'test', 'one' })
    Bolt.read_dotfile
    
    Bolt['test'].should == 'one'
    Bolt.get('test').should == 'one'
  end
  
  it 'should read and write config' do
    Bolt.set('test_two', 'two')
    
    Bolt['test_two'].should == 'two'
    Bolt.get('test_two').should == 'two'
  end
  
  it 'should read ARGV' do
    Bolt.set('verbose', 'false')
    ARGV << '-v'
    
    Bolt.read_argv
    Bolt['verbose'].should == true
  end
  
  it 'should response correctly to verbose?' do
    Bolt.set('verbose', 'true')
    Bolt.verbose?.should == true
    Bolt.set('verbose', 'false')
    Bolt.verbose?.should == false
    Bolt.set('verbose', nil)
    Bolt.verbose?.should == false
  end
  
end