require 'rubygems'
require 'spec'
require 'bolt/runners/cucumber'

describe Bolt::Runners::Cucumber do
  
  before(:all) do
    map = {
      'test' => {
        'controllers' => 'test',
        'models' => 'test'
      },
      'test2' => {
        'models' => 'lib_file'
      }
    }
    Bolt.set('feature_map', map)
    @runner = described_class.new
    
  end
  
  it 'should translate controllers' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('app/controllers/test_controller.rb').should == ["features/test.feature"]
  end
  
  it 'should translate models' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('app/models/test.rb').should == ['features/test.feature']
  end
  
  it 'should translate views' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('app/views/test/test.html.erb').should == ["features/test.feature"]
  end
  
  it 'should translate lib' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('lib/lib_file.rb').should == ["features/test2.feature"]
  end
  
  it 'should translate features to themselves' do
    @runner.stub('file_verified?').and_return(true)
    @runner.translate('features/test.feature').should == ['features/test.feature']
  end
  
  it 'should return no results if file is not present' do
    b = StringIO.new
    $stdout, old = b, $stdout
    @runner.stub('file_verified?').and_return(false)
    @runner.translate('lib/testing/test.rb').should == []
    $stdout = old
  end
  
end