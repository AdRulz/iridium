module Iridium
  module Commands
    class Generate < Generator
      include Thor::Actions

      def self.source_root
        File.expand_path '../../../../generators/application', __FILE__
      end

      desc "assetfile", "generates an Assetfile equivalent to the stock pipeline"
      def assetfile
        copy_file "Assetfile"
      end

      desc "envs", "Generate configuration files for development, test, and production enviroments"
      def envs
        directory "config"
      end

      desc "rackup", "generates a config.ru to serve your application in production"
      def rackup
        template "config.ru.tt"
      end
    end
  end
end
