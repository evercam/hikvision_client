defmodule Hikvision.Http.Utils do
  @moduledoc false

  def build_url(operation, config) do
    config
    |> Map.take([:host, :scheme, :port])
    |> Map.put(:query, query(operation))
    |> Map.put(:path, operation.path)
    |> then(&struct(URI, &1))
    |> to_string()
  end

  defp query(operation) do
    operation
    |> Map.get(:params, %{})
    |> remove_nil_values()
    |> URI.encode_query()
  end

  defp remove_nil_values(params) when is_map(params) do
    for {k, v} <- params, not is_nil(v), into: %{}, do: {k, v}
  end
end
