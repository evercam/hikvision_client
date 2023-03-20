defmodule Hikvision.ContentManagement.Storage do
  @moduledoc """
  Storage related operations
  """

  alias Hikvision.{Parsers, Operation}

  @prefix "/ISAPI/ContentMgmt/Storage"

  @doc """
  List hdd drives
  """
  @spec hdd :: Operation.t()
  def hdd() do
    Operation.new("#{@prefix}/hdd", parser: &Parsers.parse_hdd_list/1)
  end

  @doc """
  Get details about an hdd drive
  """
  @spec hdd(integer()) :: Operation.t()
  def hdd(id) do
    Operation.new("#{@prefix}/hdd/#{id}", parser: &Parsers.parse_hdd/1)
  end
end
