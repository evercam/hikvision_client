defmodule Hikvision.Streaming do
  @moduledoc false

  @doc """
  Get a picture from a live feed.

  The channel is ignored by ISAPI when the device is a **Camera**. Otherwise it must be supplied
  in the hundred format (e.g. `201` second channel, main stream. `102` first channel, sub stream)

  The following options can be supplied:
    * *width* - The width of the picture, it's only working with NVR
    * *height* - The height of the picture, it's only working with NVR
  """
  @spec snapshot(Hikvision.channel(), Keyword.t()) :: Hikvision.Operation.t()
  def snapshot(channel, opts \\ []) do
    query_params = %{
      videoResolutionWidth: Keyword.get(opts, :width),
      videoResolutionHeight: Keyword.get(opts, :height)
    }

    Hikvision.Operation.new("/ISAPI/Streaming/channels/#{channel}/picture",
      params: query_params,
      parser: fn %{body: body} -> body end
    )
  end
end
