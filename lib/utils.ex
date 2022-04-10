defmodule Pinbacker.Utils do
  def directory_tree(parent, path) do
    Enum.join([String.trim(parent, "/") | path ++ [""]], "/")
  end

  def list_all_files(filepath) do
    _list_all_files(filepath)
  end

  defp _list_all_files(filepath) do
    cond do
      String.contains?(filepath, ".git") -> []
      true -> expand_filetree(File.ls(filepath), filepath)
    end
  end

  defp expand_filetree({:ok, files}, path) do
    files
    |> Enum.flat_map(&_list_all_files("#{path}/#{&1}"))
  end

  defp expand_filetree({:error, _}, path) do
    [path]
  end
end
