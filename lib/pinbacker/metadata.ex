defmodule Pinbacker.Metadata do
  @moduledoc """
  A module that fetches metadata of the Pinterest board/pin
  """

  alias Pinbacker.HTTP

  require Logger

  use Retry.Annotation

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

  def board_slug(url), do: url |> String.trim("/") |> String.split("/") |> Enum.at(-1)

  def discard_non_pin_data(data), do: Enum.filter(data, &(&1["type"] == "pin"))

  def fetch_board_pins(board, section_pins) do
    case board do
      nil ->
        {:error, "Board not found"}

      _ ->
        {:ok, board.name,
         %{
           board_pins:
             @board_meta_enpoint
             |> pintrest_api(board, nil, [])
             |> discard_non_pin_data,
           section_pins: section_pins
         }}
    end
  end

  def get_links(:username, [username]) do
    boards = pintrest_api(@user_meta_endpoint, [username], nil, [])
    Enum.map(boards, &Map.put(&1, "slug", board_slug(Map.get(&1, "url"))))
  end

  def get_links(:board, [username, board_name]) do
    url = "https://www.pinterest.com/#{username}/#{board_name}/"

    case get_sections_and_boards(url) do
      {:ok, [boards, sections]} ->
        board =
          boards
          |> Enum.filter(&(board_slug(&1.url) == board_name))
          |> Enum.at(0)
          |> Map.put(:name, board_name)

        section_pins =
          sections
          |> Enum.map(fn section ->
            {section.slug,
             @section_meta_endpoint
             |> pintrest_api(section, nil, [])
             |> discard_non_pin_data}
          end)
          |> Map.new()

        fetch_board_pins(board, section_pins)

      {:error, error} ->
        {:error, error}
    end
  end

  def get_links(:section, [username, board_name, section_name]) do
    url = "https://www.pinterest.com/#{username}/#{board_name}/#{section_name}/"

    case get_sections_and_boards(url) do
      {:ok, [_boards, sections]} ->
        [section] = sections |> Enum.filter(&(&1.slug == section_name))

        pins =
          @section_meta_endpoint
          |> pintrest_api(section, nil, [])
          |> discard_non_pin_data()

        Logger.info("Found #{length(pins)} pins in #{board_name} #{section_name}..")

        {:ok, board_name, section_name,
         %{
           pins: pins,
           section_meta: section
         }}

      {:error, error} ->
        {:error, error}
    end
  end

  def get_links(:pin, pin_id) do
    url = "https://www.pinterest.com/pin/#{pin_id}/"

    case fetch_script_with_json(url) do
      {:ok, react_state} -> {:ok, react_state["props"]["initialReduxState"]["pins"][pin_id]}
      {:error, error} -> {:error, error}
    end
  end

  @retry with: exponential_backoff() |> randomize |> expiry(20_000)
  def get_sections_and_boards(url) do
    Logger.info("Fetching #{url}..")

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

  def pintrest_api(_, _, ["-end-"], data), do: data

  def pintrest_api(url, section, bookmark, data) do
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

    IO.write(".")
    pintrest_api(url, section, new_bookmark, new_data)
  end
end
