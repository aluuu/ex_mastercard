defmodule ExMastercard do
  use HTTPoison.Base

  @endpoint "https://www.mastercard.com/psder/eu/callPsder.do"

  @type date :: binary
  @type currency_code :: binary
  @type rate :: Decimal.t
  @type currency_code_pair :: {currency_code, currency_code}
  @type rates :: %{currency_code => rate}

  @type response :: {integer, any} | any

  @spec fetch_last_rate(currency_code_pair) :: {date, rate}
  def fetch_last_rate(codes = {source_code, destination_code}) do
    case fetch_rates(source_code, nil) do
      {rates_date, nil} -> {rates_date, fetch_rate(codes, rates_date)}
      {rates_date, rates} -> {rates_date, rates |> Map.get(destination_code)}
    end
  end

  @spec fetch_last_rate(currency_code) :: {date, rates}
  def fetch_last_rates(currency_code) do
    case fetch_rates(currency_code, nil) do
      {rates_date, nil} -> fetch_rates(currency_code, rates_date)
      r -> r
    end
  end

  @spec fetch_rate(currency_code_pair, date) :: rate
  def fetch_rate({source_code, destination_code}, date) do
    case fetch_rates(source_code, date) do
      {_, nil} -> nil
      {_, rates} -> rates |> Map.get(destination_code)
    end
  end

  @spec fetch_rates(currency_code, date) :: rate | nil
  def fetch_rates(currency_code, date) do
    data =  build_request(currency_code, date)

    response = request!(:post, @endpoint, data, [],
                        timeout: 60_000,
                        recv_timeout: 60_000)
    response = response |> process_response

    currencies = Exml.get response, "//ALPHA_CURENCY_CODE"
    rates = Exml.get(response, "//CONVERSION_RATE")
    rates_date = Exml.get(response, "//SETTLEMENT_DATE")

    case {currencies, rates} do
      {nil, nil} -> {rates_date, nil}
      {_, _} ->
        rates = rates |> Enum.map(&(Decimal.new &1))
        {rates_date, Enum.zip(currencies, rates) |> Map.new}
    end
  end

  defp build_request(currency_code, date) do
    data =
      case date do
        nil -> [service: "loadInitialValues"]
        _ -> [baseCurrency: currency_code,
             settlementDate: date,
             service: "getExchngRateDetails"]
      end
    {:form, data}
  end

  @spec process_response(HTTPoison.Response.t) :: response
  def process_response(%HTTPoison.Response{status_code: 200, body: body}) do
    Exml.parse body
  end

  def process_response(%HTTPoison.Response{status_code: status_code, body: body }) do
    { status_code, body }
  end
end
