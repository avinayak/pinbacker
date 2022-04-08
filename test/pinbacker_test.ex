defmodule PinbackerTest do
  use ExUnit.Case
  doctest Pinbacker.PathParser

  alias Pinbacker.PathParser

  test "empty path" do
    assert PathParser.parse("") == {:error, "path cannot be empty"}
  end

end
