module Hydrogen
  class Component
    class << self
      def before_compile(&block)
        callback :before_compile, &block
      end

      def javascript(&block)
        config.pipeline.js_pipelines.push block
      end
      alias js javascript

      def stylesheet(&block)
        config.pipeline.css_pipelines.push block
      end
      alias css stylesheet
    end
  end
end
