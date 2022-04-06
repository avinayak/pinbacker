defmodule Pinbacker.Metadata do
  @moduledoc """
  A module that fetches metadata of the Pinterest board/pin
  """

  import SweetXml
  alias Pinbacker.HTTP

  def get_metadata(:pin, pin_id, host) do
    with {:ok, body} <- HTTP.get(:pin, "https://#{host}/pin/#{pin_id}/"),
         {:ok, react_state} <- body |> xpath(~x"//script/text()") |> JSON.decode() do
      react_state["props"]["initialReduxState"]["pins"][pin_id]
    else
      error -> error
    end
  end
end
