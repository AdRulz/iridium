module Iridium
  class Component < Hydrogen::Component
    def paths
      @paths ||= begin
        set = Hydrogen::PathSet.new root
        set[:app].add "app"
        set[:vendor].add "vendor"
        set[:site].add "site"
        set[:tmp].add "tmp"
        set[:build].add "temp/build"
        set
      end
    end

    def app_path
      paths[:app].expanded.first
    end

    def site_path
      paths[:site].expanded.first
    end

    def vendor_path
      paths[:vendor].expanded.first
    end

    def tmp_path
      paths[:tmp].expanded.first
    end

    def build_path
      paths[:build].exapnded.first
    end
  end
end
