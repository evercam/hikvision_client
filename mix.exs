defmodule HikvisionClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :hikvision_client,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:digex_request, "~> 0.2"},
      {:sweet_xml, ">= 0.0.0", optional: true}
    ]
  end
end
