defmodule MetadataTest do
  use ExUnit.Case
  doctest Pinbacker.Metadata

  alias Pinbacker.Metadata
  alias Pinbacker.Downloader

  # test "get pin links" do
  #   assert Metadata.get_links(:pin, "207517495320779226")
  #          |> Map.get("images")
  #          |> Map.get("orig") ==
  #            %{
  #              "height" => 386,
  #              "url" =>
  #                "https://i.pinimg.com/originals/89/d1/90/89d190aa9abc57169c38347ac7f1f0bb.gif",
  #              "width" => 540
  #            }
  # end

  # test "get section links" do
  #   assert Metadata.get_links(:section, ["atulvinayak", "sys1", "sys0"]) |> Map.keys() == ["5163293311995261576", "5224888090920805547"]
  # end

  # test "get board links" do
  #   data = Metadata.get_links(:board, ["jeromep93", "avions"])
  #   [board_id] = data|> Map.keys()
  #   assert data[board_id] |> length == 469
  # end

  #  test "get user boards" do
  #   data = Metadata.get_links(:board, ["atulvinayak"])
  #   assert length(data) == 3
  # end


  # test "section" do
  #   assert Metadata.get_sections_and_boards("https://www.pinterest.com/atulvinayak/sys1/sys0/") ==
  #            {
  #              :ok,
  #              [
  #                [
  #                  %{
  #                    id: "407083322507603634",
  #                    name: "Sys1",
  #                    section_count: 2,
  #                    url: "/atulvinayak/sys1/"
  #                  }
  #                ],
  #                [
  #                  %{
  #                    id: "5163293311995261576",
  #                    slug: "sys0",
  #                    title: "Sys0"
  #                  },
  #                  %{
  #                    id: "5224888090920805547",
  #                    slug: "logo-mark",
  #                    title: "Logo Mark"
  #                  }
  #                ]
  #              ]
  #            }
  # end

  # test "board" do
  #   username = "atulvinayak"
  #   board_name = "sys2"

  #   assert Metadata.get_sections_and_boards(
  #            "https://www.pinterest.com/#{username}/#{board_name}/"
  #          ) ==
  #            {
  #              :ok,
  #              [
  #                [
  #                  %{
  #                    id: "407083322507658424",
  #                    name: "Sys2",
  #                    section_count: 0,
  #                    url: "/atulvinayak/sys2/"
  #                  }
  #                ],
  #                []
  #              ]
  #            }
  # end
end
