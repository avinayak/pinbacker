defmodule PinbackerTest do
  use ExUnit.Case
  doctest Pinbacker

  test "greets the world" do
    assert Pinbacker.hello() == :world
  end

  test "directory tree" do
    assert Pinbacker.directory_tree("root/", ["a", "b", "c"]) == "root/a/b/c/"
  end

  # test "section download" do
  #   Pinbacker.fetch("https://www.pinterest.jp/atulvinayak/sys1/logo-mark/", "./test/")
  # end

  test "board download" do
    Pinbacker.fetch("https://www.pinterest.com/rtmaurice/books-books-books/", "./test/")
  end
end
