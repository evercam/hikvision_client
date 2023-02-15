defmodule Hikvision.Streaming do
  @moduledoc false

  alias Hikvision.Client

  @spec snapshot(Hikvision.channel(), Client.t(), Keyword.t()) :: binary() | Hikvision.error()
  def snapshot(channel, client, opts \\ []) do
    query_params = %{
      videoResolutionWidth: Keyword.get(opts, :width),
      videoResolutionHeight: Keyword.get(opts, :height)
    }

    Client.request(
      client,
      :get,
      "/Streaming/channels/#{channel}/picture",
      nil,
      Keyword.put(opts, :query_params, query_params)
    )
  end
end
