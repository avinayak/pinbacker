# Pinbacker

An Elixir library/CLI to backup your Pintrest pins

## Installation

[available in Hex](https://hex.pm/packages/pinbacker), the package can be installed
by adding `pinbacker` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pinbacker, "~> 0.1.0"}
  ]
end
```

## Sample Usage

To save all the pins by user atulsvinayak to Downloads, Simply run

```elixir
Pinbacker.fetch("https://www.pinterest.jp/atulsvinayak/_saved/", "~/Downloads")
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/pinbacker](https://hexdocs.pm/pinbacker).

