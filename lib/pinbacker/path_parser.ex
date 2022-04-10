defmodule Pinbacker.PathParser do
  @moduledoc """
  A module for parsing pintrest board paths.
  """

  @unrecognizable "Unrecognizable Pinterest board path"

  def parse_uri(uri) do
    uri
    |> URI.decode()
    |> URI.parse()
  end

  def get_parts(nil) do
    {:error, @unrecognizable}
  end

  def get_parts(slash_path) do
    path_parts =
      slash_path
      |> String.trim("/")
      |> String.split("/")

    if length(path_parts) <= 3 do
      {:ok, path_parts}
    else
      {:error, @unrecognizable}
    end
  end

  def parse_job_type(parts) do
    case parts do
      [username, board_type] when board_type in ["boards", "_saved", "_created", "pins"] ->
        {:ok, :username, username}

      ["pin", pin_id] ->
        {:ok, :pin, pin_id}

      [top_level | _]
      when top_level in ["search", "categories", "topics"] ->
        {:error, "Cannot fetch search/categories/topics/more_ideas"}

      [_, _board, section] when section in ["more_ideas", "more_pins"] ->
        {:error, "Cannot fetch more_ideas/more_pins"}

      [username, board, section] ->
        {:ok, :section, [username, board, section]}

      [username, board] ->
        {:ok, :board, [username, board]}

      [username] ->
        {:ok, :username, username}

      _ ->
        {:error, @unrecognizable}
    end
  end

  def parse("") do
    {:error, "path cannot be empty"}
  end

  def parse(path) do
    with %URI{path: slash_path} <- parse_uri(path),
         {:ok, parts} <- get_parts(slash_path),
         {:ok, job, pin_source} <- parse_job_type(parts) do
      {:ok, job, pin_source}
    else
      err -> err
    end
  end
end
