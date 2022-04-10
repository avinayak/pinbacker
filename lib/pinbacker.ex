defmodule Pinbacker do
  @moduledoc """
  Documentation for `Pinbacker`.
  """

  alias Pinbacker.{PathParser, Downloader, Metadata, Utils}

  @doc """
  Hello world.

  ## Examples

      iex> Pinbacker.hello()
      :world

  """
  def hello do
    :world
  end

  def fetch(url, parent) do
    case PathParser.parse(url) do
      {:ok, :section, section_path, _host} ->
        download_section(section_path, parent)

      {:ok, :board, board_path, _host} ->
        download_board(board_path, parent)

      {:ok, :username, username, _host} ->
        boards = Metadata.get_links(:username, [username])

        IO.puts("Found #{length(boards)} boards for #{username}..")

        Enum.map(
          boards,
          &download_board([username, Map.get(&1, "slug")], parent)
        )

      _ ->
        "Unsupported URL"
    end

    IO.puts("done")

    true
  end

  defp download_section(section_path, parent) do
    save_location = Utils.directory_tree(parent, section_path)
    IO.puts("saving pins from section to " <> save_location)
    File.mkdir_p!(Path.dirname(save_location))
    {:ok, _, _, %{pins: pins}} = Metadata.get_links(:section, section_path)
    Downloader.save_pins(pins, save_location)
  end

  defp download_board(board_path, parent) do
    save_location = Utils.directory_tree(parent, board_path)
    IO.puts("saving pins from board to " <> save_location)
    File.mkdir_p!(Path.dirname(save_location))

    with {:ok, board_name, pins} <- Metadata.get_links(:board, board_path) do
      Downloader.save_pins(pins.board_pins, save_location)

      pins.section_pins
      |> Enum.map(fn {section_name, section_pins} ->
        section_dirname = Utils.directory_tree(save_location, [section_name])
        File.mkdir_p!(section_dirname)

        IO.puts(
          "saving pins from board.section #{board_name}.#{section_name} to " <> section_dirname
        )

        Downloader.save_pins(section_pins, section_dirname)
      end)

      pins.section_pins
    else
      {:error, message} ->
        IO.puts("Error: #{message}")
    end
  end

  # def fetch_pins(board, directory / "images") do

  # end
end
