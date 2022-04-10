defmodule Pinbacker do
  @moduledoc """
  Documentation for `Pinbacker`.
  """

  alias Pinbacker.{PathParser, Downloader, Metadata}
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
end
