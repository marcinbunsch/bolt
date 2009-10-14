module Bolt #:nodoc:    
  module Adapters #:nodoc:    
    module Rails #:nodoc:    
    end
  end
end

puts '** Rails found, loading adapter'
ENV['RAILS_ENV'] = 'test'

# the environment has to be loaded here or we end up with a stack level too deep error
begin
  case Bolt::Runner.pick
    when 'test_unit'
      require 'test/test_helper'
    when 'legacy_test_unit'
      require 'test/test_helper'
    when 'rspec'
      require 'spec/spec_helper'
    when 'cucumber'
      require 'config/environment.rb'
    else
      # ??
  end
rescue
  # if rails fails to load env, supply the user with a helpful message
  $stdout.puts "** ERROR - could not load Rails environment"
  $stdout.puts "** REASON: #{$!.class}: #{$!.message}"
  $stdout.puts "#{$!.backtrace.join("\n")}"
  $stdout.puts "===\n** Bolt was unable to load the Rails environment. Above is a description of the error that prevented Bolt from starting"
  exit(1)
end

# This is a hack for Rails Test::Unit to prevent raising errors when a test file is loaded again
module ActiveSupport #:nodoc:    
  module Testing #:nodoc:    
    module Declarative #:nodoc:    
      # test "verify something" do
      #   ...
      # end
      def test(name, &block)
        test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
        defined = instance_method(test_name) rescue false
        # raise "#{test_name} is already defined in #{self}" if defined # do not raise this error
        if block_given?
          define_method(test_name, &block)
        else
          define_method(test_name) do
            flunk "No implementation provided for #{name}"
          end
        end
      end
    end
  end
end

# These hacks disable caching in views
module ActionView #:nodoc:
  class PathSet #:nodoc:    
    class Path #:nodoc:    
      def eager_load_templates?
        false
      end
    end
  end
end

# disable the class check in initialize for path
module ActionView #:nodoc:
  class Template #:nodoc:    
    class Path #:nodoc:    
      def initialize(path)
        # raise ArgumentError, "path already is a Path class" if path.is_a?(Path)
        @path = path.freeze
      end
    end
  end
end

# only in rails >= 2.3.2
if Rails::VERSION::STRING =~ /^2\.3\.[2-9]/
  # make sure that type_cast always returns the ReloadablePath
  module ActionView #:nodoc:
    class PathSet #:nodoc:
      def self.type_cast(obj)
        return ReloadableTemplate::ReloadablePath.new(obj)
      end
    end
  end
end


# Rails < 2.3.0
if Rails::VERSION::STRING =~ /^2\.3\.0/ || Rails::VERSION::STRING =~ /^2\.[0-2]\.[0-9]/
  module ActionView #:nodoc:    
    # NOTE: The template that this mixin is being included into is frozen
    # so you cannot set or modify any instance variables
    module Renderable #:nodoc:    
      private
        def recompile?(path)
          true
        end
    end
  end
  
  module ActionView #:nodoc:
    class PathSet #:nodoc:    
       
       class Path #:nodoc:    
         
         # make it always return a refreshed template!
         def [](template_path)
           
           begin
             template = Template.new(template_path, path.to_s)
           rescue ::ActionView::MissingTemplate
             begin
               template_path = template_path + '.erb' if !template_path.match('.erb')
               template = Template.new(template_path, path.to_s)
             rescue ::ActionView::MissingTemplate
               
             end
           end
           return template
         end

         
         def initialize(path, load = true)
           #raise ArgumentError, "path already is a Path class" if path.is_a?(Path)
           @path = path.freeze
           reload! if load
         end
       end
       
    end
  end
  
end