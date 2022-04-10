defmodule Pinbacker.MixProject do
  use Mix.Project

  def project do
    [
      app: :pinbacker,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Pinbacker.CLI],
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/avinayak/pinbacker"
    ]
  end

  defp description do
    """
    An Elixir library/CLI to backup your Pintrest pins
    """
  end

  defp package do
    [
      name: "pinbacker",
      licenses: ["MIT"],
      contributors: ["Atul Vinayak"],
      links: %{"GitHub" => "https://github.com/avinayak/pinbacker"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :retry]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:floki, "~> 0.32.0"},
      {:json, "~> 1.4.1"},
      {:httpoison, "~> 1.8"},
      {:retry, "~> 0.15"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:distillery, "~> 2.0"}
    ]
  end
end
