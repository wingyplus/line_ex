defmodule EchoPlugTest do
  use ExUnit.Case
  doctest EchoPlug

  test "greets the world" do
    assert EchoPlug.hello() == :world
  end
end
