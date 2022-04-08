defmodule Pinbacker.Utils do
  def directory_tree(parent, path) do
    Enum.join([String.trim(parent, "/") | path ++ [""]], "/")
  end

  def name_to_slug(name) do
    name |> String.split(" ") |> Enum.map(&String.downcase/1) |> Enum.join("-") |> String.replace(".", "")
  end

end
