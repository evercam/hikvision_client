defmodule Hikvision.ContentManagement.InputProxy do
  @moduledoc """
  Input proxy operations
  """

  @prefix "/ISAPI/ContentMgmt/InputProxy"

  alias Hikvision.{Parsers, Operation}

  def status(channel) do
    Operation.new("#{@prefix}/channels/#{channel}/status",
      parser: &Parsers.parse_channel_input_proxy_status/1
    )
  end
end
