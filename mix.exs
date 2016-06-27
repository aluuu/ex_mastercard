defmodule ExMastercard.Mixfile do
  use Mix.Project

  @description """
  Mastercard FX rates fetcher
  """

  def project do
    [app: :ex_mastercard,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :httpoison, :exml]]
  end

  defp deps do
    [{:httpoison, "~> 0.8"},
     {:exml, "~> 0.1"},
     {:decimal, "~> 1.1"}]
  end
end
