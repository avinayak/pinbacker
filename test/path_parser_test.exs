defmodule PathParserTest do
  use ExUnit.Case
  doctest Pinbacker.PathParser

  alias Pinbacker.PathParser

  test "empty path" do
    assert PathParser.parse("") == {:error, "path cannot be empty"}
  end

  test "path without host" do
    assert PathParser.parse(
             "/peggy0020018/%E8%B1%AC%E5%A4%A7%E4%BE%BF_moodboard/%E5%9C%93%E5%9C%93%E8%83%96%E8%83%96bobo%E5%BD%A2/"
           ) ==
             {:ok, :section, ["peggy0020018", "豬大便_moodboard", "圓圓胖胖bobo形"], nil}
  end

  test "path with host" do
    assert PathParser.parse("https://www.pinterest.jp/annecortey/illustrations/") ==
             {:ok, :board, ["annecortey", "illustrations"], "www.pinterest.jp"}
  end

  test "path with subboard" do
    assert PathParser.parse("https://www.pinterest.jp/annecortey/illustrations/more_path") ==
             {:ok, :section, ["annecortey", "illustrations", "more_path"], "www.pinterest.jp"}
  end

  test "path with username" do
    assert PathParser.parse("https://www.pinterest.jp/annecortey") ==
             {:ok, :username, "annecortey", "www.pinterest.jp"}
  end

  test "path with sub-subboard" do
    assert PathParser.parse("https://www.pinterest.jp/annecortey/illustrations/more_path/more") ==
             {:error, "Unrecognizable Pinterest board path"}
  end

  test "path with categories" do
    assert PathParser.parse("https://www.pinterest.jp/categories/more_path/more") ==
             {:error, "Cannot fetch search/categories/topics/more_ideas"}
  end

  test "path with more_ideas" do
    assert PathParser.parse("https://www.pinterest.jp/dom/more_path/more_ideas") ==
             {:error, "Cannot fetch more_ideas/more_pins"}
  end

  test "path without some host" do
    assert PathParser.parse("https://www.google.com") ==
             {:error, "Unrecognizable Pinterest board path"}
  end
end
