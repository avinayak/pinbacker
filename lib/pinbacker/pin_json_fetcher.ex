defmodule Pinbacker.PinJsonFetcher do
  @moduledoc """
  A module that fetches metadata of the Pinterest board/pin
  """
  alias Pinbacker.Metadata
  use Retry.Annotation

  def get_pins_json(pins), do: Enum.map(pins, &get_pin_json/1)

  @retry with: exponential_backoff() |> randomize |> expiry(20_000)
  def get_pin_json(pin) do
    case pin do
      %{"images" => images} ->
        {:ok, images}

      _ ->
        {:error, "Unsupported file format"}
    end
  end

  def save_single_pin(pin_id) do
    case Metadata.get_links(:pin, pin_id) do
      {:ok, react_state} -> get_pin_json(react_state)
      {:error, error} -> {:error, error}
    end
  end

  def save_section(section_path) do
    {:ok, _, _, %{pins: pins}} = Metadata.get_links(:section, section_path)
    get_pins_json(pins)
  end

  def save_board(board_path) do
    case Metadata.get_links(:board, board_path) do
      {:ok, _board_name, pins} ->
        board_pins = get_pins_json(pins.board_pins)

        section_pins =
          pins.section_pins
          |> Enum.map(fn {_section_name, section_pins} -> get_pins_json(section_pins) end)

        board_pins ++ section_pins

      {:error, message} ->
        Logger.info("Error: #{message}")
    end
  end
end
