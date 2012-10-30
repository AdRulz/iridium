module Hydrogen
  class Component
    class Configuration
      def initialize
        @@options ||= {}
        @@options[:commands] ||= []
      end

      def commands
        @@options[:commands]
      end

      def respond_to?(name)
        super || @@options.key?(name.to_sym)
      end

      private
      def options
        @@options
      end

      def method_missing(name, *args, &blk)
        if name.to_s =~ /=$/
          @@options[$`.to_sym] = args.first
        elsif @@options.key?(name)
          @@options[name]
        else
          super
        end
      end
    end

    class AppProxy
      def initialize
        @extensions, @includes = [], []
      end

      def extend(klass)
        @extensions << klass
      end

      def include(klass)
        @includes << klass
      end

      def extensions
        @extensions
      end

      def includes
        @includes
      end
    end

    class << self
      def loaded
        @loaded ||= []
      end

      def inherited(base)
        loaded << base
      end

      def config
        instance.config
      end

      def command(klass, name)
        commands << { :class => klass, :name => name }
      end

      def commands
        config.commands
      end

      def app
        instance.app
      end

      def instance
        @instance ||= new
      end
    end

    def config
      @config ||= Configuration.new
    end

    def app
      @app ||= AppProxy.new
    end
  end
end
