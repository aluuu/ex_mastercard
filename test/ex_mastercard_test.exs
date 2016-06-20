defmodule ExMastercardTest do
  use ExUnit.Case
  alias Decimal, as: D
  doctest ExMastercard

  test "fetches latest rates" do
    {_date, rates} = ExMastercard.fetch_last_rates("RUB")
    assert Map.size(rates) > 0
  end

  test "fetches latest single rate" do
    {_date, rate} = ExMastercard.fetch_last_rate({"RUB", "USD"})
    assert not D.equal?(D.new(0), rate)
  end

  test "returns nil if there's no rates for given date" do
    {_date, rates} = ExMastercard.fetch_rates("RUB", "09/12/2999")
    assert rates == nil
  end
end
