defmodule Hikvision do
  @moduledoc """
  """

  alias Hikvision.{Client, Streaming, System}

  @type error :: {:error, :unauthorized} | {:error, :server_error} | {:error, map()}
  @type success :: {:ok, map(), Client.t()}

  @spec new_client(Client.host(), String.t(), String.t(), Client.req_handler()) :: Client.t()
  defdelegate new_client(host, username, password, handler \\ nil), to: Client, as: :new

  @spec system_status(Client.t()) :: success() | error()
  defdelegate system_status(client), to: System, as: :status

  @doc """
  Get a picture from a live feed.

  The channel is ignored by ISAPI when the device is a **Camera**. Otherwise it must be supplied
  in the hundred format (e.g. `201` second channel, main stream. `102` first channel, sub stream)

  The following options can be supplied:
    * *width* - The width of the picture, it's only working with NVR
    * *height* - The height of the picture, it's only working with NVR
  """
  @spec snapshot(Client.t(), String.t(), Keyword.t()) :: binary() | error()
  defdelegate snapshot(client, channel, opts \\ []), to: Streaming
end
