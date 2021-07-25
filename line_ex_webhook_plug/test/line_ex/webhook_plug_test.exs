defmodule LineEx.WebhookPlugTest do
  use ExUnit.Case
  doctest LineEx.WebhookPlug

  test "greets the world" do
    assert LineEx.WebhookPlug.hello() == :world
  end
end
