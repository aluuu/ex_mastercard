defmodule ExMastercardTest do
  use ExUnit.Case
  alias Decimal, as: D
  doctest ExMastercard

  test "fetches single rate for specific date" do
    {_date, rate} = ExMastercard.fetch_rate("RUB", "USD", "2016-10-19")
    assert not D.equal?(D.new(0), rate)
  end

  test "fetches nil if rate for specific date is unavailable" do
    {_date, rate} = ExMastercard.fetch_rate("RUB", "USD", "2016-10-01")
    assert is_nil(rate)
  end
end
