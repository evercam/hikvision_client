defmodule Hikvision.Streaming do
  @moduledoc false

  alias Hikvision.Client

  @spec snapshot(Client.t(), String.t(), Keyword.t()) :: binary() | Hikvision.error()
  def snapshot(client, channel, opts \\ []) do
    query_params = %{
      videoResolutionWidth: Keyword.get(opts, :width),
      videoResolutionHeight: Keyword.get(opts, :height)
    }

    Client.request(client, :get, "/Streaming/channels/#{channel}/picture", nil,
      query_params: query_params
    )
  end
end
