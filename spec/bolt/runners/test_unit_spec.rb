require 'spec'
require 'bolt/runners/test_unit'

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
    @runner.stub('file_verified?').and_return(false)
    @runner.translate('lib/testing/test.rb').should == []
  end
  
end