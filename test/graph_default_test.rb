require './test/test_helper'
describe StateMachines::Graph do
  def setup
    @graph = StateMachines::Graph.new('test')
  end

  def test_should_have_a_default_font
    assert_equal('Arial' ,@graph.font)
  end

  def test_should_use_current_directory_for_filepath
    assert_equal('doc/state_machines/test.png' ,@graph.file_path)
  end

  def test_should_have_a_default_file_format
    assert_equal('png' ,@graph.file_format)
  end

  def test_should_have_a_default_orientation
    assert_equal('TB' ,@graph[:rankdir].source)
  end
end
