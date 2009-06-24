module Bolt
  module Adapters
    module Rails
    end
  end
end

puts '** Rails found, loading environment'
ENV['RAILS_ENV'] = 'test'
require 'config/environment.rb'

# This is a hack for Rails Test::Unit to prevent raising errors when a test file is loaded again
module ActiveSupport
  module Testing
    module Declarative
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
    class Path
      def eager_load_templates?
        false
      end
    end
  end
end

# disable the class check in initialize for path
module ActionView #:nodoc:
  class Template
    class Path
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
  module ActionView
    # NOTE: The template that this mixin is being included into is frozen
    # so you cannot set or modify any instance variables
    module Renderable
      private
        def recompile?(path)
          true
        end
    end
  end
  
  module ActionView #:nodoc:
    class PathSet #:nodoc:    
       
       class Path
         
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