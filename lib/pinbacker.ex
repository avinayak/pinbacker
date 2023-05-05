defmodule Pinbacker do
  @moduledoc """
  Documentation for `Pinbacker`.
  """

  alias Pinbacker.{PathParser, Downloader, Metadata, PinJsonFetcher}
  require Logger

  def fetch(url, parent) do
    case PathParser.parse(url) do
      {:ok, :pin, pin_id} ->
        Downloader.save_single_pin(pin_id, parent)

      {:ok, :section, section_path} ->
        Downloader.save_section(section_path, parent)

      {:ok, :board, board_path} ->
        Downloader.save_board(board_path, parent)

      {:ok, :username, username} ->
        boards = Metadata.get_links(:username, [username])

        Logger.info("Found #{length(boards)} boards for #{username}..")

        for board <- boards do
          Downloader.save_board([username, Map.get(board, "slug")], parent)
        end

      {:error, error} ->
        Logger.error("Error: #{error}")
    end

    Logger.info("Done")

    true
  end

  def metadata(url) do
    case PathParser.parse(url) do
      {:ok, :pin, pin_id} ->
        PinJsonFetcher.save_single_pin(pin_id)

      {:ok, :section, section_path} ->
        PinJsonFetcher.save_section(section_path)

      {:ok, :board, board_path} ->
        PinJsonFetcher.save_board(board_path)

      {:ok, :username, username} ->
        boards = Metadata.get_links(:username, [username])

        Logger.info("Found #{length(boards)} boards for #{username}..")

        boards
        |> Enum.map(fn board ->
          Metadata.get_links(:board, [username, Map.get(board, "slug")])
        end)

      {:error, error} ->
        Logger.error("Error: #{error}")
    end
  end
end
