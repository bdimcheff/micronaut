lib_path = File.expand_path(File.dirname(__FILE__) + "/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

require 'micronaut'
require 'rubygems'
gem :mocha

require File.expand_path(File.dirname(__FILE__) + "/resources/example_classes")

module Micronaut
  module Matchers
    def fail
      raise_error(::Micronaut::Expectations::ExpectationNotMetError)
    end

    def fail_with(message)
      raise_error(::Micronaut::Expectations::ExpectationNotMetError, message)
    end
  end
end

def remove_last_describe_from_world
  Micronaut.world.behaviours.pop
end

def not_in_editor?
  ['TM_MODE', 'EMACS', 'VIM'].all? { |k| !ENV.has_key?(k) }
end

Micronaut.configure do |c|
  c.mock_with :mocha
  c.color_enabled = not_in_editor?
  c.filter_run :focused => true
end
