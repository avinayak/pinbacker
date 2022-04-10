defmodule Pinbacker.Utils do
  @moduledoc """
  Utils for Pinbacker
  """

  def directory_tree(parent, path) do
    Enum.join([String.trim(parent, "/") | path ++ [""]], "/")
  end

  def list_all_files(filepath) do
    expand_filetree(File.ls(filepath), filepath)
  end

  defp expand_filetree({:ok, files}, path) do
    Enum.flat_map(files, &list_all_files("#{path}/#{&1}"))
  end

  defp expand_filetree({:error, _}, path) do
    [path]
  end
end
