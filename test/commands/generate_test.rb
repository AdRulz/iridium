require 'test_helper'

class GenerateTest < GeneratorTestCase
  def command
    Iridium::Commands::Generate
  end

  def test_generator_creates_an_index
    invoke "index"

    assert_file 'app/public/index.html.erb'
    index_path = destination_root.join('app', 'public', 'index.html.erb')
    content = read index_path

    assert_includes content, %Q{<script src="/application.js"></script>}
    assert_includes content, %Q{<link href="/application.css" rel="stylesheet">}
    assert_includes content, %Q{minispade.require("test_app/boot");}
  end

  def test_generator_creates_an_assetfile
    invoke "assetfile"

    assert_file 'Assetfile'

    content = read "Assetfile"

    stock_assetfile = File.expand_path "../../../lib/iridium/Assetfile", __FILE__

    assert_equal File.read(stock_assetfile), content
  end

  def test_generator_creates_conf_directories
    invoke "envs"

    assert_file 'config', 'development.rb'
    assert_file 'config', 'test.rb'
    assert_file 'config', 'production.rb'

    assert_file 'config', 'settings.yml'
  end

  def test_generator_creates_confg_ru
    invoke "rackup"

    assert_file 'config.ru'

    content = read destination_root.join('config.ru')

    assert_includes content, 'run TestApp'
  end
end
