defmodule PinbackerTest do
  use ExUnit.Case
  doctest Pinbacker

  test "greets the world" do
    assert Pinbacker.hello() == :world
  end

  test "directory tree" do
    assert Pinbacker.directory_tree("root/", ["a", "b", "c"]) == "root/a/b/c"
  end
end
