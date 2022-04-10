defmodule Pinbacker.Downloader do
  @moduledoc """
  A module that fetches metadata of the Pinterest board/pin
  """
  alias Pinbacker.{HTTP, Utils, Metadata}
  use Retry.Annotation

  def save_pins(pins, directory), do: Enum.map(pins, &save_pin(&1, directory))

  @retry with: exponential_backoff() |> randomize |> expiry(20_000)
  def save_pin(pin, location) do
    true_loc = Path.expand(Path.dirname(location))
    File.mkdir_p!(true_loc)

    case pin do
      %{"images" => images} ->
        url = images["orig"]["url"]
        %URI{path: path} = URI.parse(url)
        fname = Enum.join([true_loc, path |> String.split("/") |> Enum.at(-1)], "/")

        HTTP.download!(:img, url, fname)
        {:ok, fname}

      _ ->
        {:error, "Unsupported file format"}
    end
  end

  def save_single_pin(pin_id, parent) do
    save_location = Utils.directory_tree(parent, [])
    Logger.info("Saving pin to " <> save_location)

    case Metadata.get_links(:pin, pin_id) do
      {:ok, react_state} -> save_pin(react_state, save_location)
      {:error, error} -> {:error, error}
    end
  end

  def save_section(section_path, parent) do
    save_location = Utils.directory_tree(parent, section_path)
    Logger.info("Saving pins from section to " <> save_location)

    {:ok, _, _, %{pins: pins}} = Metadata.get_links(:section, section_path)
    save_pins(pins, save_location)
  end

  def save_board(board_path, parent) do
    save_location = Utils.directory_tree(parent, board_path)
    Logger.info("Saving pins from board to " <> save_location)

    case Metadata.get_links(:board, board_path) do
      {:ok, board_name, pins} ->
        save_pins(pins.board_pins, save_location)

        for {section_name, section_pins} <- pins.section_pins do
          section_dirname = Utils.directory_tree(save_location, [section_name])
          File.mkdir_p!(section_dirname)

          Logger.info(
            "Saving pins from board.section #{board_name}.#{section_name} to " <> section_dirname
          )

          save_pins(section_pins, section_dirname)
        end

        pins.section_pins

      {:error, message} ->
        Logger.info("Error: #{message}")
    end
  end
end
