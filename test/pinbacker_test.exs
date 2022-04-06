defmodule PinbackerTest do
  use ExUnit.Case
  doctest Pinbacker

  test "greets the world" do
    assert Pinbacker.hello() == :world
  end
end
