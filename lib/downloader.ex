defmodule Pinbacker.Downloader do
  @moduledoc """
  A module that fetches metadata of the Pinterest board/pin
  """
  alias Pinbacker.HTTP
  alias Pinbacker.Metadata

  def save_pin(%{"images" => images}, location) do
    url = images["orig"]["url"]
    %URI{path: path} = URI.parse(url)
    fname = path |> String.split("/") |> Enum.at(-1)
    HTTP.download!(:img, url, location <> fname)
    {:ok, fname}
  end

  def save_pin(_, _) do
    {:error, "Unsupported file format"}
  end

end
