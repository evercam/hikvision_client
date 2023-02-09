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

    def parse_search_profile(%{body: xml}) do
      xml
      |> SweetXml.xpath(~x"//CMSearchProfile",
        search_profile: ~x"./searchProfile/text()"s,
        text_search: ~x"./textSearch/text()"s,
        max_search_timespans: ~x"./maxSearchTimespans/text()"i,
        max_search_sources: ~x"./maxSearchSources/text()"oi,
        max_search_tracks: ~x"./maxSearchTracks/text()"i,
        max_search_metadata: ~x"./maxSearchMetadatas/text()"oi,
        max_search_match_results: ~x"./maxSearchMatchResults/text()"i,
        max_concurrent_searches: ~x"./maxConcurrentSearches/text()"i
      )
    end

    def parse_content_search(%{body: xml}) do
      xml
      |> SweetXml.xpath(~x"//CMSearchResult",
        status: ~x"./responseStatusStrg/text()"s,
        total: ~x"./numOfMatches/text()"i,
        items: [
          ~x"./matchList/searchMatchItem"l,
          source_id: ~x"./sourceID/text()"s,
          track_id: ~x"./trackID/text()"i,
          start_time: ~x"./timeSpan/startTime/text()"s,
          end_time: ~x"./timeSpan/endTime/text()"s,
          content_type: ~x"./mediaSegmentDescriptor/contentType/text()"s,
          codec: ~x"./mediaSegmentDescriptor/codecType/text()"s,
          rate_type: ~x"./mediaSegmentDescriptor/rateType/text()"s,
          playback_uri: ~x"./mediaSegmentDescriptor/playbackURI/text()"s,
          lock_status: ~x"./mediaSegmentDescriptor/lockStatus/text()"s,
          name: ~x"./mediaSegmentDescriptor/name/text()"s
        ]
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
