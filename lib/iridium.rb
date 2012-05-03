require "iridium/version"

require 'yaml'
require 'rack/rewrite'
require 'rake-pipeline'
require 'rake-pipeline/middleware'
require 'rake-pipeline-web-filters'
require 'rake-pipeline-web-filters/erb_filter'

require 'iridium/reverse_proxy'

require 'iridium/middleware/add_header'
require 'iridium/middleware/add_cookie'

require 'iridium/pipeline'
require 'iridium/rack'

module Iridium
  class Application
    include Pipeline
    include Rack

    attr_accessor :root
    attr_reader :config

    class << self
      def configure(&block)
        @callbacks ||= []
        @callbacks << block
      end

      def configurations
        @callbacks || []
      end

      def root=(val)
        @root = val
      end

      def root
        @root
      end
    end

    def initialize
      boot!
    end

    def env
      ENV['RACK_ENV'] || 'development'
    end

    def boot!
      @config = OpenStruct.new(YAML.load(ERB.new(File.read("#{root}/config/settings.yml")).result)[env])

      begin
        require "#{root}/config/application.rb"

        # Now require the individual enviroment files
        # that can be used to add middleware and all the
        # other standard rack stuff
        require "#{root}/config/#{env}.rb"
      rescue LoadError
      end
    end

    def root
      self.class.root
    end

    def production?
      env == 'production'
    end

    def development?
      env == 'development'
    end
  end
end
