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
      {:error, error} -> {:error, error}
    end
  end

  def board_slug(url) do
    url |> String.trim("/") |> String.split("/") |> Enum.at(-1)
  end

  def get_links(:username, [username]) do
    boards = fetch_user([username], nil, [])
    Enum.map(boards, &Map.put(&1, "slug", board_slug(Map.get(&1, "url"))))
  end

  def get_links(:board, [username, board_name]) do
    url = "https://www.pinterest.com/#{username}/#{board_name}/"

    with {:ok, [boards, sections]} <- get_sections_and_boards(url) do
      board =
        boards
        |> Enum.filter(&(board_slug(&1.url) == board_name))
        |> Enum.at(0)

      section_pins =
        sections
        |> Enum.map(fn section ->
          {section.slug,
           fetch_section([username, board_name, section.slug], section, nil, [])
           |> Enum.filter(&(&1["type"] == "pin"))}
        end)
        |> Map.new()

      case board do
        nil ->
          {:error, "Board not found"}

        _ ->
          {:ok, board_name,
           %{
             board_pins:
               fetch_board([username, board_name], board, nil, [])
               |> Enum.filter(&(&1["type"] == "pin")),
             section_pins: section_pins,
             section_metadata: sections
           }}
      end
    else
      {:error, error} -> {:error, error}
    end
  end

  def get_links(:section, [username, board_name, section_name]) do
    url = "https://www.pinterest.com/#{username}/#{board_name}/#{section_name}/"

    with {:ok, [_boards, sections]} <- get_sections_and_boards(url) do
      [section] = sections |> Enum.filter(&(&1.slug == section_name))

      pins =
        fetch_section([username, board_name, section_name], section, nil, [])
        |> Enum.filter(&(&1["type"] == "pin"))

      IO.puts("Found #{length(pins)} pins in #{board_name} #{section_name}..")

      {:ok, board_name, section_name,
       %{
         pins: pins,
         section_meta: section
       }}
    else
      {:error, e} ->
        {:error, e}
    end
  end

  def get_links(:pin, pin_id) do
    url = "https://www.pinterest.com/pin/#{pin_id}/"

    with {:ok, react_state} <- fetch_script_with_json(url) do
      react_state["props"]["initialReduxState"]["pins"][pin_id]
    else
      {:error, error} -> {:error, error}
    end
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
      {:error, error} -> {:error, error}
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
        {:error, error} -> {:error, error}
      end

    IO.write(".")
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
        {:error, error} -> {:error, error}
      end

    IO.write(".")
    fetch_board([username, board_name], board, new_bookmark, new_data)
  end

  defp user_link_query_params(bookmark, uname) do
    options = %{
      "isPrefetch" => false,
      "privacy_filter" => "all",
      "sort" => "alphabetical",
      "field_set_key" => "profile_grid_item",
      "username" => uname,
      "page_size" => 25,
      "group_by" => "visibility",
      "include_archived" => true,
      "redux_normalize_feed" => true
    }

    options =
      case bookmark do
        nil -> options
        bm -> Map.merge(options, %{"bookmarks" => [bm]})
      end

    %{
      "source_url" => uname,
      "data" =>
        JSON.encode!(%{
          "options" => options,
          "context" => %{}
        })
    }
  end

  def fetch_user(_, ["-end-"], data) do
    data
  end

  def fetch_user([username], bookmark, data) do
    url = "https://www.pinterest.com/resource/BoardsResource/get/"

    params = user_link_query_params(bookmark, username)

    {:ok, new_data, new_bookmark} =
      with {:ok, json_string} <- HTTP.get(:img, url, params),
           {:ok, json} <- JSON.decode(json_string) do
        new_data = json["resource_response"]["data"] ++ data
        new_bookmark = json["resource"]["options"]["bookmarks"]
        {:ok, new_data, new_bookmark}
      else
        {:error, error} -> {:error, error}
      end

    IO.write(".")
    fetch_user([username], new_bookmark, new_data)
  end
end

# Pinbacker.Metadata(["atulvinayak", "sys1", "art-sonstige"], nil)
