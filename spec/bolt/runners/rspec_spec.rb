require 'spec'
require 'bolt/runners/rspec'

describe Bolt::Runners::RSpec do
  
  before(:all) do
    @runner = described_class.new
  end
  
  it 'should translate controllers' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('app/controllers/test_controller.rb').should == ['spec/controllers/test_controller_spec.rb']
  end
  
  it 'should translate models' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('app/models/test.rb').should == ['spec/models/test_spec.rb']
  end
  
  it 'should translate views' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('app/views/test/test.html.erb').should == ['spec/controllers/test_controller_spec.rb']
  end
  
  it 'should translate lib' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('lib/test.rb').should == ['spec/test_spec.rb']
  end
  
  it 'should translate lib with subfolders' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('lib/testing/test.rb').should == ['spec/testing/test_spec.rb']
  end
  
  it 'should translate specs to themselves' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('spec/controllers/test_controller_spec.rb').should == ['spec/controllers/test_controller_spec.rb']
    @runner.translate('spec/test_spec.rb').should == ['spec/test_spec.rb']
    @runner.translate('spec/testing/test_spec.rb').should == ['spec/testing/test_spec.rb']
  end
  
  it 'should return no results if file is not present' do
    @runner.stub('file_verified?').and_return(false)
    @runner.translate('lib/testing/test.rb').should == []
  end
  
end