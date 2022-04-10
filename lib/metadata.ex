defmodule Pinbacker.Metadata do
  @moduledoc """
  A module that fetches metadata of the Pinterest board/pin
  """

  alias Pinbacker.HTTP

  require Logger

  @section_meta_endpoint "https://www.pinterest.com/resource/BoardSectionPinsResource/get/"
  @board_meta_enpoint "https://www.pinterest.com/resource/BoardFeedResource/get/"
  @user_meta_endpoint "https://www.pinterest.com/resource/BoardsResource/get/"

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
    boards = fetch_pins(@user_meta_endpoint, [username], nil, [])
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
           fetch_pins(@section_meta_endpoint, section, nil, [])
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
               fetch_pins(@board_meta_enpoint, board, nil, [])
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
        fetch_pins(@section_meta_endpoint, section, nil, [])
        |> Enum.filter(&(&1["type"] == "pin"))

      Logger.info("Found #{length(pins)} pins in #{board_name} #{section_name}..")

      {:ok, board_name, section_name,
       %{
         pins: pins,
         section_meta: section
       }}
    else
      {:error, error} ->
        {:error, error}
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
    case fetch_script_with_json(url) do
      {:ok, react_state} ->
        parent = react_state["props"]["initialReduxState"]
        boards = parent["boards"]
        sections = parent["boardsections"]

        boards_metadata =
          boards
          |> Map.keys()
          |> Enum.filter(fn board_id -> !is_nil(boards[board_id]["collaborating_users"]) end)
          |> Enum.map(
            &%{
              url: boards[&1]["url"],
              id: &1,
              name: boards[&1]["name"],
              section_count: boards[&1]["section_count"],
              type: :board
            }
          )

        sections_metadata =
          sections
          |> Map.keys()
          |> Enum.map(
            &%{
              id: &1,
              title: sections[&1]["title"],
              slug: sections[&1]["slug"],
              type: :section
            }
          )

        {:ok, [boards_metadata, sections_metadata]}

      {:error, error} ->
        {:error, error}
    end
  end

  defp wrap_query_params(options, bookmark) do
    %{
      "data" =>
        JSON.encode!(%{
          "options" =>
            case bookmark do
              nil -> options
              bm -> Map.merge(options, %{"bookmarks" => [bm]})
            end,
          "context" => %{}
        })
    }
  end

  defp query_params(%{type: :board} = board) do
    %{
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
  end

  defp query_params(%{type: :section} = section) do
    %{
      "isPrefetch" => false,
      "field_set_key" => "react_grid_pin",
      "is_own_profile_pins" => false,
      "page_size" => 25,
      "redux_normalize_feed" => true,
      "section_id" => section.id
    }
  end

  defp query_params(uname) do
    %{
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
  end

  def fetch_pins(_, _, ["-end-"], data) do
    data
  end

  def fetch_pins(url, section, bookmark, data) do
    params = query_params(section) |> wrap_query_params(bookmark)

    {:ok, new_data, new_bookmark} =
      with {:ok, json_string} <- HTTP.get(:img, url, params),
           {:ok, json} <- JSON.decode(json_string) do
        new_data = json["resource_response"]["data"] ++ data
        new_bookmark = json["resource"]["options"]["bookmarks"]
        {:ok, new_data, new_bookmark}
      else
        {:error, error} -> {:error, error}
      end

    fetch_pins(url, section, new_bookmark, new_data)
  end
end
