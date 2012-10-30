require 'test_helper'

class CompileCommandTest < MiniTest::Unit::TestCase
  def setup ; end
  def teardown ; end

  def test_compile_command_calls_compile
    app = mock
    Iridium.application = app

    app.expects(:compile)

    Iridium::Pipeline::CompileCommand.new.invoke(:compile)
  end
end
