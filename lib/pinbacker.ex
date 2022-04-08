defmodule Pinbacker do
  @moduledoc """
  Documentation for `Pinbacker`.
  """

  alias Pinbacker.PathParser

  @doc """
  Hello world.

  ## Examples

      iex> Pinbacker.hello()
      :world

  """
  def hello do
    :world
  end

  def directory_tree(parent, path) do
    Enum.join([String.trim(parent, "/") | path], "/")
  end

  def fetch(url, save_location) do
    File.mkdir_p!(Path.dirname(save_location))

    case PathParser.parse(url) do
      {:ok, :section, section_path} -> true
    end
  end

  # def fetch_pins(board, directory / "images") do

  # end
end
