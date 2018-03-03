defmodule KarmelTest do
  use ExUnit.Case
  doctest Karmel

  test "greets the world" do
    assert Karmel.hello() == :world
  end
end
