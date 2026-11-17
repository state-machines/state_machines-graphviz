# frozen_string_literal: true

require_relative 'test_helper'
require 'tmpdir'

# StateMachines::Graphviz.draw, which the state_machines:draw task calls
class GraphvizDrawTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir('state_machines-graphviz')
  end

  def teardown
    FileUtils.rm_rf(@dir)
  end

  def test_draw_uses_graphviz_whichever_renderer_machines_use
    klass = Class.new
    Object.const_set(:GraphvizDrawLamp, klass)
    klass.state_machine(initial: :off) { event(:switch_on) { transition off: :on } }
    previous = StateMachines::Machine.renderer
    StateMachines::Machine.renderer = StateMachines::STDIORenderer

    StateMachines::Graphviz.draw(' GraphvizDrawLamp ', path: @dir, format: 'dot')

    assert_path_exists(File.join(@dir, 'GraphvizDrawLamp_state.dot'))
  ensure
    StateMachines::Machine.renderer = previous
    Object.send(:remove_const, :GraphvizDrawLamp)
  end

  def test_draw_needs_a_class
    assert_raises(ArgumentError) { StateMachines::Graphviz.draw(' , ', path: @dir) }
  end
end
