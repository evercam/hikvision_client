defmodule Hikvision.System do
  @moduledoc false

  alias Hikvision.{Operation, Parsers}

  @prefix "/ISAPI/System"

  @doc """
  Get information about the device
  """
  @spec device_info() :: Operation.t()
  def device_info() do
    Operation.new("#{@prefix}/deviceInfo", parser: &Parsers.parse_device_info/1)
  end

  @doc """
  Get the system status of the Camera/NVR
  """
  @spec status() :: Operation.t()
  def status(), do: Operation.new("#{@prefix}/status", parser: &Parsers.parse_system_status/1)

  @doc """
  Reboot the device
  """
  @spec reboot() :: Operation.t()
  def reboot(),
    do: Operation.new("#{@prefix}/reboot", http_method: :put)

  @spec time() :: Operation.t()
  def time(), do: Operation.new("#{@prefix}/time", parser: &Parsers.parse_system_time/1)

  @spec ntp_servers() :: Operation.t()
  def ntp_servers(),
    do: Operation.new("#{@prefix}/time/NtpServers", parser: &Parsers.parse_time_ntp_servers/1)
end
