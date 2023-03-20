defmodule Hikvision.PTZ do
  @moduledoc """
  PTZ(pan/tilt/zoom) operations
  """

  alias Hikvision.Operation

  @prefix "/ISAPI/PTZCtrl"

  @doc """
  Initialize the lens
  """
  @spec reset_focus(binary()) :: Operation.t()
  def reset_focus(channel) do
    Operation.new("#{@prefix}/channels/#{channel}/onepushfoucs/reset", http_method: :put)
  end
end
