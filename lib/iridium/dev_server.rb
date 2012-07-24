require "rack/server"
require "rake-pipeline/middleware"

module Iridium
  class DevServer < Rack::Server
    class NotFound
      def call(env)
        [404, { "Content-Type" => "text/plain" }, ["not found"]]
      end
    end

    def app
      Rack::Builder.new do
        Iridium.application.config.middleware.each do |middleware|
          use middleware.name, *middleware.args, &middleware.block
        end

        Iridium.application.config.proxies.each_pair do |url, to|
          proxy url, to
        end

        use ::Rack::Rewrite do
          rewrite '/', '/index.html'
          rewrite %r{^\/?[^\.]+\/?(\?.*)?$}, '/index.html$1'
        end

        use Middleware::DefaultIndex, Iridium.application
        use Rake::Pipeline::Middleware, Iridium.application.pipeline
        run NotFound.new
      end
    end
  end
end
