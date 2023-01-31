defmodule Hikvision.Client do
  @moduledoc false

  use DigexRequest

  @type host :: binary()

  @type t :: %__MODULE__{
    scheme: :http | :https,
    host: host(),
    session: DigexRequest.t(),
    prefix: String.t()
  }

  defstruct scheme: :http, host: nil, session: nil, prefix: "/ISAPI"

  @spec new(host(), String.t(), String.t()) :: Hikvision.Client.t()
  def new(host, username, password) do
    %__MODULE__{
      host: host,
      session: DigexRequest.new(:get, "", username, password)
    }
  end

  @spec path(Hikvision.Client.t(), any) :: Hikvision.Client.t()
  def path(%__MODULE__{session: req} = client, path) do
    url = "#{client.scheme}://#{client.host}#{client.prefix}#{path}"
    req = %{req | url: url}
    %__MODULE__{client | session: req}
  end

  def request(%__MODULE__{session: req} = client, parser \\ fn x -> x end) do
    case request(req) do
      {:ok, resp, req} -> {:ok, parser.(resp), %__MODULE__{client | session: req}}
      other -> other
    end
  end
end
