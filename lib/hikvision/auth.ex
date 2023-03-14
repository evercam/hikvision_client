defmodule Hikvision.Auth do
  @moduledoc false

  use GenServer

  alias Hikvision.Auth.DigestHeaderBuilder

  @ets_name :hikvision_auth_header

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def inject_auth_headers(http_method, url, headers, username, password, resp_headers \\ [])

  def inject_auth_headers(http_method, url, headers, username, password, []) do
    uri = URI.parse(url)

    header =
      case :ets.lookup(@ets_name, header_key(uri)) do
        [{_, builder}] ->
          %DigestHeaderBuilder{builder | method: http_method, uri: uri.path}
          |> DigestHeaderBuilder.calculate()
          |> DigestHeaderBuilder.build()

        _ ->
          Base.encode64("#{username}:#{password}")
      end

    [{"authorization", header} | headers]
  end

  def inject_auth_headers(http_method, url, headers, username, password, resp_headers) do
    uri = URI.parse(url)
    auth_header = www_auth_header(resp_headers)

    if String.starts_with?(auth_header, "Digest") do
      auth_header
      |> DigestHeaderBuilder.new(http_method, uri.path, username, password)
      |> tap(&:ets.insert(@ets_name, {header_key(uri), &1}))
      |> DigestHeaderBuilder.calculate()
      |> DigestHeaderBuilder.build()
      |> then(&[{"authorization", &1} | headers])
    else
      headers
    end
  end

  @impl GenServer
  def init(nil) do
    :ets.new(@ets_name, [:set, :public, :named_table])
    {:ok, nil}
  end

  defp www_auth_header(headers) do
    headers
    |> Map.new()
    |> Map.get("www-authenticate", "")
  end

  defp header_key(uri), do: {uri.scheme, uri.host, uri.port}
end
