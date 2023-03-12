defmodule Hikvision.Http.Client do
  @moduledoc false

  @type http_method :: :get | :post | :put | :delete | :head

  @spec request(
          http_method(),
          binary(),
          binary(),
          [{binary(), binary()}, ...],
          Path.t() | nil,
          term()
        ) ::
          {:ok, term()} | {:error, term()} | :ok
  def request(http_method, url, req_body, headers, dest \\ nil, http_opts \\ []) do
    options = if dest, do: [stream: to_charlist(dest)], else: []

    case :httpc.request(
           http_method,
           req(http_method, url, headers, req_body),
           http_options(http_opts),
           options
         ) do
      {:ok, :saved_to_file} ->
        :ok

      {:ok, {{_, status, _}, headers, body}} ->
        {:ok, %{status: status, headers: headers_from_charlist(headers), body: to_string(body)}}

      {:error, error} ->
        {:error, error}
    end
  end

  defp req(http_method, url, headers, body) when http_method in [:post, :put, :patch] do
    {to_charlist(url), headers_to_charlist(headers), to_charlist(content_type(headers)), body}
  end

  defp req(_http_method, url, headers, _body) do
    {to_charlist(url), headers_to_charlist(headers)}
  end

  defp content_type(headers) do
    Enum.find_value(headers, fn {key, value} ->
      if key == "content-type", do: value
    end)
  end

  defp http_options(opts), do: Keyword.take(opts, [:connect_timeout, :timeout])

  def headers_to_charlist(headers) do
    for {k, v} <- headers, do: {to_charlist(k), to_charlist(v)}
  end

  def headers_from_charlist(headers) do
    for {k, v} <- headers, do: {to_string(k), to_string(v)}
  end
end
