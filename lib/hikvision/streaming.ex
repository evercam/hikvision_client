defmodule Hikvision.Streaming do
  @moduledoc """
  Streaming operations
  """

  alias Hikvision.{Parsers, Operation}

  @type channel :: integer() | binary()

  @prefix "/ISAPI/Streaming"

  @doc """
  Get encoding configuration of the available channels
  """
  @spec channels() :: Operation.t()
  def channels() do
    Operation.new("#{@prefix}/channels", parser: &Parsers.parse_channels_config/1)
  end

  @doc """
  Get encoding configuration of a channel
  """
  @spec channel(channel()) :: Operation.t()
  def channel(channel) do
    Operation.new("#{@prefix}/channels/#{channel}", parser: &Parsers.parse_channel_config/1)
  end

  @doc """
  Get a picture from a live feed.

  The channel is ignored by ISAPI when the device is a **Camera**. Otherwise it must be supplied
  in the hundred format (e.g. `201` second channel, main stream. `102` first channel, sub stream)

  The following options can be supplied:
    * *width* - The width of the picture, it's only working with NVR
    * *height* - The height of the picture, it's only working with NVR
  """
  @spec snapshot(channel(), Keyword.t()) :: Hikvision.Operation.t()
  def snapshot(channel, opts \\ []) do
    query_params = %{
      videoResolutionWidth: Keyword.get(opts, :width),
      videoResolutionHeight: Keyword.get(opts, :height)
    }

    Operation.new("#{@prefix}/channels/#{channel}/picture",
      params: query_params,
      parser: &Parsers.body/1
    )
  end
end
