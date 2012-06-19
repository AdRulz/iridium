module Iridium
  module Rack
    extend ActiveSupport::Concern

    class Builder < ::Rack::Builder 
      def proxy(url, to)
        use ReverseProxy do
          reverse_proxy /^#{url}(\/.*)$/, "#{to}$1"
        end
      end
    end

    module ClassMethods
      def call(env)
        new.app.call(env)
      end
    end

    def app
      server = self

      builder = Builder.new

      builder.use Middleware::RackLintCompatibility
      builder.use ::Rack::Deflater

      if config.perform_caching
        builder.use ::Rack::Cache, config.cache
        builder.use ::Rack::ConditionalGet
        builder.use Middleware::StaticAssets, config.root, config.cache_control
      end

      config.middleware.each do |middleware|
        builder.use middleware.name, *middleware.args, &middleware.block
      end

      config.proxies.each do |proxy|
        builder.proxy proxy.url, proxy.to
      end

      builder.use ::Rack::Rewrite do
        rewrite '/', '/index.html'
        rewrite %r{^\/?[^\.]+\/?(\?.*)?$}, '/index.html$1'
      end

      if development?
        builder.use Middleware::PipelineReset, server
        builder.use Rake::Pipeline::Middleware, pipeline
      end

      builder.run ::Rack::Directory.new root.join('site')

      builder.to_app
    end
  end
end
