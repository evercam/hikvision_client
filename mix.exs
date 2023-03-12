defmodule HikvisionClient.MixProject do
  use Mix.Project

  @version "0.1.0"
  @repo "https://github.com/evercam/hikvision_client"

  def project do
    [
      app: :hikvision_client,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "HikvisionClient",
      source_url: @repo,
      description: "Hikvision ISAPI client",
      docs: [
        main: "Hikivision",
        source_ref: "v#{@version}",
        source_url: @repo,
        extras: ["README.md"]
      ],
      package: [
        licenses: ["MIT"],
        links: %{
          "Github" => @repo
        }
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets]
    ]
  end

  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:sweet_xml, ">= 0.0.0", optional: true},
      {:bypass, "~> 2.1", only: :test},
      {:jason, "~> 1.4", only: :test},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
