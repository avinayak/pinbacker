defmodule MetadataTest do
  use ExUnit.Case
  doctest Pinbacker.Metadata

  alias Pinbacker.Metadata

  test "empty metagaf" do
    path = Metadata.get_metadata(:pin, "667166132302229226", "www.pinterest.jp")
    Pinbacker.Downloader.save_pin(path, "./test/")
    assert true
  end

end
