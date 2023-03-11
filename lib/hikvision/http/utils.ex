defmodule Hikvision.Http.Utils do
  @moduledoc false

  alias Hikvision.Http.DigestHeaderBuilder

  def build_url(operation, config) do
    config
    |> Map.new()
    |> Map.take([:host, :scheme, :port])
    |> Map.put(:query, query(operation))
    |> Map.put(:path, operation.path)
    |> then(&struct(URI, &1))
    |> to_string()
  end

  def digest_auth?(headers) do
    headers
    |> www_auth_header()
    |> String.starts_with?("Digest")
  end

  def with_auth_header(operation, config, resp_headers \\ []) do
    auth_header = www_auth_header(resp_headers)

    header =
      if String.starts_with?(auth_header, "Digest") do
        auth_header
        |> DigestHeaderBuilder.new(
          operation.http_method,
          operation.path,
          config[:username],
          config[:password]
        )
        |> DigestHeaderBuilder.calculate()
        |> DigestHeaderBuilder.build()
      else
        Base.encode64("#{config[:username]}:#{config[:password]}")
      end

    [{"authorization", header} | operation.headers]
  end

  @spec encode_query_params(map() | nil) :: binary()
  def encode_query_params(nil), do: nil

  def encode_query_params(params) do
    params
    |> remove_nil_values()
    |> URI.encode_query()
  end

  def headers_to_charlist(headers) do
    for {k, v} <- headers, do: {to_charlist(k), to_charlist(v)}
  end

  def headers_from_charlist(headers) do
    for {k, v} <- headers, do: {to_string(k), to_string(v)}
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
