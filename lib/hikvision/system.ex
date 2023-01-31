defmodule Hikvision.System do
  @moduledoc false

  alias Hikvision.{Client, Parsers}

  @doc """
  Get the system status of the Camera/NVR
  """
  @spec status(Client.t()) :: Hikvision.success() | Hikvision.error()
  def status(%Client{} = client) do
    client
    |> Client.path("/System/status")
    |> Client.request(&Parsers.parse_system_status/1)
  end
end
