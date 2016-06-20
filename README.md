# ExMastercard

Mastercard exchange rates fetcher

## Installation

```elixir
   def deps do
      [{:ex_mastercard, git: "git://github.com/aluuu/ex_mastercard.git", branch: "master"}]
   end
```

## Usage

```elixir
ExMastercard.fetch_last_rates("RUB")
ExMastercard.fetch_last_rate({"RUB", "USD"})
```
