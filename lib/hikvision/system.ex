defmodule Hikvision.System do
  @moduledoc false

  alias Hikvision.{Client, Parsers}

  @spec status(Client.t()) :: Hikvision.success() | Hikvision.error()
  def status(client),
    do:
      Client.request(client, :get, "/System/status", nil, parser: &Parsers.parse_system_status/1)
end
