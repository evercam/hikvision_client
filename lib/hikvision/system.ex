defmodule Hikvision.System do
  @moduledoc false

  alias Hikvision.{Operation, Parsers}

  @doc """
  Get the system status of the Camera/NVR
  """
  @spec status() :: Operation.t()
  def status(), do: Operation.new("/ISAPI/System/status", parser: &Parsers.parse_system_status/1)
end
