defmodule MetadataTest do
  use ExUnit.Case
  doctest Pinbacker.Metadata

  alias Pinbacker.Metadata
  alias Pinbacker.Downloader

  test "get pin links" do
    assert Metadata.get_links(:pin, "207517495320779226")
           |> Map.get("images")
           |> Map.get("orig") ==
             %{
               "height" => 386,
               "url" =>
                 "https://i.pinimg.com/originals/89/d1/90/89d190aa9abc57169c38347ac7f1f0bb.gif",
               "width" => 540
             }
  end

  test "get section links" do
    {:ok, "analog", "outdoor", %{pins: pins}} =
      Metadata.get_links(:section, ["atulsvinayak", "analog", "outdoor"])

    assert length(pins) == 3
  end

  test "get board links" do
    {:ok, _board_slug, board} = Metadata.get_links(:board, ["atulsvinayak", "analog"])
    assert board.board_pins |> length == 34
  end

  test "get user boards" do
    data = Metadata.get_links(:username, ["atulsvinayak"])
    assert length(data) == 2
  end

  test "section" do
    assert Metadata.get_sections_and_boards(
             "https://www.pinterest.jp/atulsvinayak/analog/outdoor/"
           ) ==
             {:ok,
              [
                [
                  %{
                    id: "1090152722239571253",
                    name: "Analog",
                    section_count: 1,
                    url: "/atulsvinayak/analog/",
                    type: :board
                  }
                ],
                [%{id: "5225236608711713313", slug: "outdoor", title: "Outdoor", type: :section}]
              ]}
  end

  test "board" do
    assert Metadata.get_sections_and_boards("https://www.pinterest.jp/atulsvinayak/portraits/") ==
             {:ok,
              [
                [
                  %{
                    id: "1090152722239571260",
                    name: "Portraits",
                    section_count: 0,
                    url: "/atulsvinayak/portraits/",
                    type: :board
                  }
                ],
                []
              ]}
  end
end
