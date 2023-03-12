defmodule Hikvision.Config do
  @moduledoc false

  @config [:scheme, :host, :port, :username, :password]

  @type t :: %__MODULE__{
          scheme: binary(),
          host: binary(),
          port: 1..65536,
          username: binary(),
          password: binary()
        }

  defstruct scheme: "http", host: "localhost", port: 80, username: nil, password: nil

  @spec new(Keyword.t()) :: t()
  def new(config_overrides \\ []) do
    %__MODULE__{}
    |> merge_app_env()
    |> merge_overrides(config_overrides)
  end

  defp merge_app_env(config) do
    app_config = Application.get_all_env(:hikvision) |> Map.new() |> Map.take(@config)
    Map.merge(config, app_config)
  end

  defp merge_overrides(config, config_overrides) do
    Map.new(config_overrides)
    |> Map.take(@config)
    |> then(&Map.merge(config, &1))
  end
end