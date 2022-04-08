defmodule Pinbacker.Downloader do
  @moduledoc """
  A module that fetches metadata of the Pinterest board/pin
  """
  alias Pinbacker.HTTP

  def save_pins(pins, directory) do
    pins
    |> Enum.map(&save_pin(&1, directory))
  end

  def save_pin(%{"images" => images}, location) do
    url = images["orig"]["url"]
    %URI{path: path} = URI.parse(url)
    fname = path |> String.split("/") |> Enum.at(-1)

    IO.puts("saving pin " <> fname <> " to " <> location)

    HTTP.download!(:img, url, location <> fname)
    {:ok, fname}
  end

  def save_pin(_, _) do
    {:error, "Unsupported file format"}
  end
end
