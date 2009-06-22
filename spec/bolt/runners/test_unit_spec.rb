require 'spec'
require 'bolt/runners/test_unit'

# test fixture for testing of class clearing
module Bolt
  class ClassForTesting
    def one; end
    def two; end
  end
  module Nested
    class ClassForTesting
      def three; end
      def four; end
    end
  end
end

describe Bolt::Runners::TestUnit do
  
  before(:all) do
    @runner = described_class.new
  end
  
  it 'should translate controllers' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('app/controllers/test_controller.rb').should == ['test/functional/test_controller_test.rb']
  end
  
  it 'should translate models' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('app/models/test.rb').should == ['test/unit/test_test.rb']
  end
  
  it 'should translate views' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('app/views/test/test.html.erb').should == ['test/functional/test_controller_test.rb']
  end
  
  it 'should translate lib' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('lib/test.rb').should == ['test/unit/test_test.rb']
  end
  
  it 'should translate lib with subfolders' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('lib/testing/test.rb').should == ['test/unit/testing/test_test.rb']
  end
  
  it 'should translate tests to itself' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('test/functional/test_controller_test.rb').should == ['test/functional/test_controller_test.rb']
    @runner.translate('test/unit/test_test.rb').should == ['test/unit/test_test.rb']
    @runner.translate('test/unit/testing/test_test.rb').should == ['test/unit/testing/test_test.rb']
  end
  
  it 'should return no results if file is not present' do
     b = StringIO.new
      $stdout, old = b, $stdout
    @runner.stub('file_verified?').and_return(false)
    @runner.translate('lib/testing/test.rb').should == []
    $stdout = old
  end
  
  it 'should return no results if file is not present' do
    Bolt::ClassForTesting.should_not be_nil
    Bolt::Nested::ClassForTesting.should_not be_nil
    @tester1 = Bolt::ClassForTesting.new
    @tester1.respond_to?(:one).should be_true
    @tester1.respond_to?(:two).should be_true
    @tester2 = Bolt::Nested::ClassForTesting.new
    @tester2.respond_to?(:three).should be_true
    @tester2.respond_to?(:four).should be_true
    @runner.clear_class(Bolt::ClassForTesting)
    @runner.clear_class(Bolt::Nested::ClassForTesting)
  
    # it should applied to current instances
    @tester1.respond_to?(:one).should be_false
    @tester1.respond_to?(:two).should be_false
    @tester2.respond_to?(:three).should be_false
    @tester2.respond_to?(:four).should be_false
    
    # and to new instances
    @tester1a = Bolt::ClassForTesting.new
    @tester2a = Bolt::Nested::ClassForTesting.new
    @tester1a.respond_to?(:one).should be_false
    @tester1a.respond_to?(:two).should be_false
    @tester2a.respond_to?(:three).should be_false
    @tester2a.respond_to?(:four).should be_false
  end
  
end