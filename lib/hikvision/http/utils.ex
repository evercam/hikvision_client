defmodule Hikvision.HTTP.Utils do
  @moduledoc false

  @spec encode_query_params(map() | nil) :: binary()
  def encode_query_params(nil), do: nil

  def encode_query_params(params) do
    params
    |> remove_nil_values()
    |> URI.encode_query()
  end

  defp remove_nil_values(params) when is_map(params) do
    for {k, v} <- params, not is_nil(v), into: %{}, do: {k, v}
  end
end
