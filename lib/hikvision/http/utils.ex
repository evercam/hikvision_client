defmodule Hikvision.Http.Utils do
  @moduledoc false

  alias Hikvision.Http.DigestHeaderBuilder

  def build_url(operation, config) do
    config
    |> Map.take([:host, :scheme, :port])
    |> Map.put(:query, query(operation))
    |> Map.put(:path, operation.path)
    |> then(&struct(URI, &1))
    |> to_string()
  end

  def with_auth_header(operation, config, resp_headers \\ []) do
    auth_header = www_auth_header(resp_headers)

    header =
      if String.starts_with?(auth_header, "Digest") do
        auth_header
        |> DigestHeaderBuilder.new(
          operation.http_method,
          operation.path,
          config.username,
          config.password
        )
        |> DigestHeaderBuilder.calculate()
        |> DigestHeaderBuilder.build()
      else
        Base.encode64("#{config.username}:#{config.password}")
      end

    [{"authorization", header} | operation.headers]
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

  defp www_auth_header(headers) do
    headers
    |> Map.new()
    |> Map.get("www-authenticate", "")
  end
end
