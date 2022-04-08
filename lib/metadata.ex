defmodule Pinbacker.Metadata do
  @moduledoc """
  A module that fetches metadata of the Pinterest board/pin
  """

  alias Pinbacker.HTTP

  def fetch_script_with_json(url) do
    with {:ok, body} <- HTTP.get(:pin, url),
         {:ok, document} <- Floki.parse_document(body),
         [{_, _, [script]} | _] <- Floki.find(document, "script[type='application/json']"),
         {:ok, react_state} <- JSON.decode(script) do
      {:ok, react_state}
    else
      error -> error
    end
  end

  def get_links(:board, [username]) do
    url = "https://www.pinterest.com/#{username}/"

    # with {:ok, [board, section]} <- get_boards_by_userlink(url) do
    #   fetch_section([username, board_name], [board, section], nil, [])
    # else
    #   error -> error
    # end
  end

  def get_links(:board, [username, board_name]) do
    url = "https://www.pinterest.com/#{username}/#{board_name}/"

    with {:ok, [[board], _sections]} <- get_sections_and_boards(url) do
      %{board.id => fetch_board([username, board_name], board, nil, [])}
    else
      error -> error
    end
  end

  def get_links(:section, [username, board_name, section_name]) do
    url = "https://www.pinterest.com/#{username}/#{board_name}/#{section_name}/"

    with {:ok, [_boards, sections]} <- get_sections_and_boards(url) do
      sections
      |> Enum.map(fn section ->
        {section.id,
         %{
           pins: fetch_section([username, board_name, section_name], section, nil, []),
           section_meta: section
         }}
      end)
      |> Map.new()
    else
      error -> error
    end
  end

  def get_links(:pin, pin_id) do
    url = "https://www.pinterest.com/pin/#{pin_id}/"

    with {:ok, react_state} <- fetch_script_with_json(url) do
      react_state["props"]["initialReduxState"]["pins"][pin_id]
    else
      error -> error
    end
  end

  def get_boards_by_userlink(url) do
  end

  def get_sections_and_boards(url) do
    with {:ok, react_state} <- fetch_script_with_json(url) do
      parent = react_state["props"]["initialReduxState"]
      boards = parent["boards"]
      sections = parent["boardsections"]

      boards_metadata =
        boards
        |> Map.keys()
        |> Enum.map(
          &%{
            url: boards[&1]["url"],
            id: &1,
            name: boards[&1]["name"],
            section_count: boards[&1]["section_count"]
          }
        )

      sections_metadata =
        sections
        |> Map.keys()
        |> Enum.map(
          &%{
            id: &1,
            title: sections[&1]["title"],
            slug: sections[&1]["slug"]
          }
        )

      {:ok, [boards_metadata, sections_metadata]}
    else
      error -> error
    end
  end

  defp section_links_query_params(bookmark, section, source_url) do
    options = %{
      "isPrefetch" => false,
      "field_set_key" => "react_grid_pin",
      "is_own_profile_pins" => false,
      "page_size" => 25,
      "redux_normalize_feed" => true,
      "section_id" => section.id
    }

    options =
      case bookmark do
        nil -> options
        bm -> Map.merge(options, %{"bookmarks" => [bm]})
      end

    %{
      "source_url" => source_url,
      "data" =>
        JSON.encode!(%{
          "options" => options,
          "context" => %{}
        })
    }
  end

  def fetch_section(_, _, ["-end-"], data) do
    data
  end

  def fetch_section([username, board_name, section_name], section, bookmark, data) do
    # recursively fetch all the pins for a section
    url = "https://www.pinterest.com/resource/BoardSectionPinsResource/get/"
    source_url = "//#{username}/#{board_name}/#{section.slug}/"
    params = section_links_query_params(bookmark, section, source_url)

    {:ok, new_data, new_bookmark} =
      with {:ok, json_string} <- HTTP.get(:img, url, params),
           {:ok, json} <- JSON.decode(json_string) do
        new_data = json["resource_response"]["data"] ++ data
        new_bookmark = json["resource"]["options"]["bookmarks"]
        {:ok, new_data, new_bookmark}
      else
        error -> error
      end

    fetch_section([username, board_name, section_name], section, new_bookmark, new_data)
  end

  defp board_links_query_params(bookmark, board, source_url) do
    options = %{
      "isPrefetch" => false,
      "field_set_key" => "react_grid_pin",
      "is_own_profile_pins" => false,
      "page_size" => 25,
      "redux_normalize_feed" => true,
      "board_id" => board.id,
      "board_url" => board.url,
      "filter_section_pins" => true,
      "layout" => "default"
    }

    options =
      case bookmark do
        nil -> options
        bm -> Map.merge(options, %{"bookmarks" => [bm]})
      end

    %{
      "source_url" => source_url,
      "data" =>
        JSON.encode!(%{
          "options" => options,
          "context" => %{}
        })
    }
  end

  def fetch_board(_, _, ["-end-"], data) do
    data
  end

  def fetch_board([username, board_name], board, bookmark, data) do
    # recursively fetch all the pins for a section
    url = "https://www.pinterest.com/resource/BoardFeedResource/get/"
    source_url = "//#{username}/#{board_name}/"
    params = board_links_query_params(bookmark, board, source_url)

    {:ok, new_data, new_bookmark} =
      with {:ok, json_string} <- HTTP.get(:img, url, params),
           {:ok, json} <- JSON.decode(json_string) do
        new_data = json["resource_response"]["data"] ++ data
        new_bookmark = json["resource"]["options"]["bookmarks"]
        {:ok, new_data, new_bookmark}
      else
        error -> error
      end

    fetch_board([username, board_name], board, new_bookmark, new_data)
  end
end

# Pinbacker.Metadata(["atulvinayak", "sys1", "art-sonstige"], nil)
