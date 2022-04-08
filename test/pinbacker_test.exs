defmodule PinbackerTest do
  use ExUnit.Case
  doctest Pinbacker

  test "greets the world" do
    assert Pinbacker.hello() == :world
  end

  test "directory tree" do
    assert Pinbacker.Utils.directory_tree("root/", ["a", "b", "c"]) == "root/a/b/c/"
  end

  test "name to slug" do
    assert Pinbacker.Utils.name_to_slug("Hello World Computer.exe") == "hello-world"
  end

  # test "section download" do
  #   Pinbacker.fetch("https://www.pinterest.jp/atulvinayak/sys1/logo-mark/", "./test/")
  # end

  # test "board download" do
  #   Pinbacker.fetch("https://www.pinterest.com/rtmaurice/books-books-books/", "./test/")
  # end

  # @tag timeout: :infinity
  # test "board download" do
  #   Pinbacker.fetch("https://www.pinterest.jp/atulvinayak/sys1/", "./test/")
  # end

  @tag timeout: :infinity
  test "user download" do
    Pinbacker.fetch("https://www.pinterest.jp/faonpourtoi", "./test/")
  end
end
