if Code.ensure_loaded?(SweetXml) do
  defmodule Hikvision.Parsers do
    @moduledoc false

    import SweetXml, only: [sigil_x: 2]

    def parse_system_status(%{body: xml}) do
      xml
      |> SweetXml.xpath(~x"//DeviceStatus",
        current_device_time: ~x"./currentDeviceTime/text()"s,
        device_uptime: ~x"./deviceUpTime/text()"i,
        status: ~x"./deviceStatus"s,
        cpus: [
          ~x"./CPUList/CPU"lo,
          description: ~x"./cpuDescription/text()"s,
          usage: ~x"./cpuUtilization/text()"i
        ],
        memory: [
          ~x"./MemoryList/Memory"lo,
          description: ~x"./memoryDescription/text()"s,
          usage: ~x"./memoryUsage/text()"s |> SweetXml.transform_by(&to_float/1),
          available: ~x"./memoryAvailable/text()"s |> SweetXml.transform_by(&to_float/1)
        ],
        file_handles: ~x"./openFileHandles/text()"io
      )
    end

    def parse_error(%{body: xml}) do
      xml
      |> SweetXml.xpath(~x"//ResponseStatus",
        endpoint: ~x"./requestURL/text()"s,
        status_code: ~x"./statusCode/text()"i,
        code: ~x"./subStatusCode/text()"s,
        description: ~x"./statusString/text()"s
      )
    end

    defp to_float(value) do
      case value |> String.trim() |> Float.parse() do
        {value, ""} -> value
        _ -> 0.0
      end
    end
  end
end
