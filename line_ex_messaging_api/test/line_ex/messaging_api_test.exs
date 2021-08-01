defmodule LineEx.MessagingApiTest do
  use ExUnit.Case
  doctest LineEx.MessagingApi

  test "greets the world" do
    assert LineEx.MessagingApi.hello() == :world
  end
end
