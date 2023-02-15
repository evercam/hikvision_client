defmodule Hikvision.HTTP.Utils do
  @moduledoc false

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

  defp remove_nil_values(params) when is_map(params) do
    for {k, v} <- params, not is_nil(v), into: %{}, do: {k, v}
  end
end
