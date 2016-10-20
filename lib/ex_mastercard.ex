defmodule ExMastercard do
  use HTTPoison.Base

  @endpoint "https://www.mastercard.us/settlement/currencyrate/"

  @type date :: binary
  @type currency_code :: binary
  @type rate :: Decimal.t
  @type currency_code_pair :: {currency_code, currency_code}
  @type rates :: %{currency_code => rate}

  @type response :: {integer, any} | any

  @spec fetch_rate(currency_code, currency_code, date) :: rate | nil
  def fetch_rate(source_code, destination_code, date) do
    params =  build_params(source_code, destination_code, date)

    url = @endpoint <> params

    response =
      get!(url, [], timeout: 60_000, recv_timeout: 60_000)
      |> process_response

    rate =
      case response["type"] do
        nil ->
          response |> Map.get("data") |> Map.get("conversionRate") |> Decimal.new
        _ -> nil
      end
    {date, rate}
  end

  defp build_params(source_code, destination_code, date) do
    date =
      case date do
        nil -> DateTime.utc_now |> DateTime.to_date |> Date.to_iso8601
        _ -> date
      end

    "fxDate=#{date};transCurr=#{source_code};crdhldBillCurr=#{destination_code};bankFee=0.00;transAmt=1.00/conversion-rate"
  end

  @spec process_response(HTTPoison.Response.t) :: response
  def process_response(%HTTPoison.Response{status_code: 200, body: body}) do
    Poison.Parser.parse! body
  end

  def process_response(%HTTPoison.Response{status_code: status_code, body: body }) do
    { status_code, body }
  end
end
