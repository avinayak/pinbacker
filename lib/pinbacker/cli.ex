defmodule Pinbacker.CLI do
  @help_text """
  Usage:
    pinbacker  -p pintrest_url -d download_location
  Examples:
    pinbacker -p https://www.pinterest.com/pin/1234/ -d ~/Downloads/
  """

  require Logger

  def main(args) do
    options = [
      switches: [pintrest_url: :string, download_location: :string],
      aliases: [p: :pintrest_url, d: :download_location]
    ]

    case OptionParser.parse(args, options) do
      {[pintrest_url: pintrest_url, download_location: download_location], _, _} ->
        Logger.info("Fetching #{pintrest_url}..")
        Pinbacker.fetch(pintrest_url, download_location)

      _ ->
        IO.puts(@help_text)
    end
  end
end
