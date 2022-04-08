defmodule Pinbacker do
  @moduledoc """
  Documentation for `Pinbacker`.
  """

  alias Pinbacker.{PathParser, Downloader, Metadata}

  @doc """
  Hello world.

  ## Examples

      iex> Pinbacker.hello()
      :world

  """
  def hello do
    :world
  end

  def directory_tree(parent, path) do
    Enum.join([String.trim(parent, "/") | path ++ [""]], "/")
  end

  def fetch(url, parent) do
    case PathParser.parse(url) do
      {:ok, :section, [_, board_name, section_name] = section_path, _host} ->
        save_location = directory_tree(parent, section_path)
        IO.puts("saving pins from section to " <> save_location)
        File.mkdir_p!(Path.dirname(save_location))

        {:ok, ^board_name, ^section_name, %{pins: pins}} =
          Metadata.get_links(:section, section_path)

        Downloader.save_pins(pins, save_location)
        IO.puts("done")

      {:ok, :board, [_, board_name] = board_path, _host} ->
        save_location = directory_tree(parent, board_path)
        IO.puts("saving pins from board to " <> save_location)
        Metadata.get_links(:board, board_path) |> IO.inspect

      _ ->
        "Unsupported URL"
    end

    true
  end

  # def fetch_pins(board, directory / "images") do

  # end
end
