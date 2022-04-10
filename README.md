# Pinbacker

An Elixir library/CLI to backup your Pintrest pins.

## Installation

[Get it from Hex](https://hex.pm/packages/pinbacker). the package can be installed
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
Pinbacker.fetch("https://www.pinterest.jp/atulsvinayak/", "~/Downloads")
```

Pinbacker accepts these Pintrest URL formats:
  * `https://www.pinterest.com/<username>/`
  * `https://www.pinterest.com/<username>/<board_name>/`
  * `https://www.pinterest.com/<username>/<board_name>/<section_name>`

