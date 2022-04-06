defmodule Pinbacker do
  @moduledoc """
  Documentation for `Pinbacker`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Pinbacker.hello()
      :world

  """
  def hello do
    :world
  end

  def url_to_board_path(url) do
    url.split("/")[-1]
  end

  # def fetch_pins(board, directory / "images") do

  # end
end
