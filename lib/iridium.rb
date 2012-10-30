require 'iridium/version'
require 'hydrogen'

require 'active_support/concern'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'

require 'active_support/ordered_options'

require 'thor'
require 'thin'
require 'json'
require 'yaml'
require 'erb'
require 'execjs'
require 'compass'

require 'rack/rewrite'
require 'rake-pipeline'
require 'rake-pipeline/middleware'
require 'rake-pipeline/drop_matcher'
require 'rake-pipeline/sorted_pipeline'
require 'rake-pipeline/iridium_helper'

require 'rake-pipeline-web-filters'
require 'rake-pipeline-web-filters/sass_filter_patch'
require 'rake-pipeline-web-filters/handlebars_filter_patch'
require 'rake-pipeline-web-filters/erb_filter'
require 'rake-pipeline-web-filters/i18n_filter'
require 'rake-pipeline-web-filters/manifest_filter'

# Declare the top level module with some utility 
# methods that other pieces of code need before filling
# in the rest

module Iridium
  class Error < StandardError ; end
  class MissingFile < Error ; end
  class MissingTestHelper < Error ; end
  class IncorrectLoadPath < Error ; end

  class << self
    def application
      @application
    end

    def application=(app)
      @application = app
    end

    def js_lib_path
      File.expand_path("../iridium/casperjs/lib", __FILE__)
    end

    def vendor_path
      Pathname.new(File.expand_path("../../vendor", __FILE__))
    end

    def load!
      return if Iridium.application

      begin
        require "#{Dir.pwd}/application"
      rescue LoadError
        $stderr.puts "Could not find application.rb. Are you in your app's root?"
        abort
      end
    end

    def env
      ENV['IRIDIUM_ENV'] || ENV['RACK_ENV'] || 'development'
    end
  end
end

require 'iridium/component'
require 'iridium/engine'
require 'iridium/pipeline'
require 'iridium/compass'
require 'iridium/rack'
require 'iridium/testing'
require 'iridium/jslint'
require 'iridium/application'

require 'iridium/generators'
require 'iridium/cli'
