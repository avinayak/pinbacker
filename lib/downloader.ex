defmodule Pinbacker.Downloader do
  @moduledoc """
  A module that fetches metadata of the Pinterest board/pin
  """
  alias Pinbacker.HTTP
  use Retry.Annotation

  def save_pins(pins, directory) do
    pins
    |> Enum.map(&save_pin(&1, directory))
  end

  @retry with: exponential_backoff() |> randomize |> expiry(20_000)
  def save_pin(pin, location) do
    case pin do
      %{"images" => images} ->
        url = images["orig"]["url"]
        %URI{path: path} = URI.parse(url)
        fname = path |> String.split("/") |> Enum.at(-1)

        HTTP.download!(:img, url, location <> fname)
        {:ok, fname}

      _ ->
        {:error, "Unsupported file format"}
    end
  end
end
