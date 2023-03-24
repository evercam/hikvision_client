if Code.ensure_loaded?(SweetXml) do
  defmodule Hikvision.Parsers do
    @moduledoc false

    import SweetXml, only: [sigil_x: 2, transform_by: 2]

    def body({:ok, %{body: body}}), do: {:ok, body}

    # System
    def parse_system_status({:ok, %{body: xml}}) do
      parsed_body =
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
            usage: ~x"./memoryUsage/text()"s |> transform_by(&to_float/1),
            available: ~x"./memoryAvailable/text()"s |> transform_by(&to_float/1)
          ],
          file_handles: ~x"./openFileHandles/text()"io
        )

      {:ok, parsed_body}
    end

    def parse_device_info({:ok, %{body: xml}}) do
      {:ok,
       xml
       |> SweetXml.xpath(~x"//DeviceInfo",
         device_id: ~x"./deviceID/text()"s,
         device_name: ~x"./deviceName/text()"s,
         device_description: ~x"./deviceDescription/text()"so,
         device_status: ~x"./deviceStatus/text()"s,
         device_location: ~x"./deviceLocation/text()"so,
         model: ~x"./model/text()"s,
         serial_number: ~x"./serialNumber/text()"s,
         mac_address: ~x"./macAddress/text()"s,
         firmware_version: ~x"./firmwareVersion/text()"s,
         firmware_released_date: ~x"./firmwareReleasedDate/text()"so,
         boot_version: ~x"./bootVersion/text()"so,
         boot_released_date: ~x"./bootReleasedDate/text()"so,
         hardware_version: ~x"./hardwareVersion/text()"so,
         encoder_version: ~x"./encoderVersion/text()"so,
         encoder_released_date: ~x"./encoderReleasedDate/text()"so,
         decoder_version: ~x"./decoderVersion/text()"so,
         decoder_released_date: ~x"./decoderReleasedDate/text()"so,
         software_version: ~x"./softwareVersion/text()"so,
         capacity: ~x"./capacity/text()"io,
         used_capacity: ~x"./usedCapacity/text()"io,
         device_type: ~x"./deviceType/text()"s,
         telecontrol_id: ~x"./telecontrolID/text()"io
       )}
    end

    def parse_system_time({:ok, %{body: xml}}) do
      {:ok,
       SweetXml.xpath(xml, ~x"//Time",
         time_mode: ~x"./timeMode/text()"s,
         local_time: ~x"./localTime/text()"s,
         timezone: ~x"./timeZone/text()"s
       )}
    end

    def parse_time_ntp_servers({:ok, %{body: xml}}) do
      {:ok,
       SweetXml.xpath(xml, ~x"//NTPServerList/NTPServer"l,
         id: ~x"./id/text()"i,
         addressing_format_type: ~x"./addressingFormatType/text()"s,
         host_name: ~x"./hostName/text()"so,
         ip_address: ~x"./ipAddress/text()"so,
         ipv6_address: ~x"./ipv6Address/text()"so,
         port_no: ~x"./portNo/text()"i,
         synchronize_interval: ~x"./synchronizeInterval/text()"io
       )}
    end

    # Content Management
    def parse_search_profile({:ok, %{body: xml}}) do
      parsed_body =
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

      {:ok, parsed_body}
    end

    def parse_content_search({:ok, %{body: xml}}) do
      parsed_body =
        xml
        |> SweetXml.xpath(~x"//CMSearchResult",
          id: ~x"./searchID/text()"s,
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

      {:ok, parsed_body}
    end

    def parse_hdd_list({:ok, %{body: xml}}) do
      {:ok, do_parse_hdd(xml, ~x"//hddList/hdd"l)}
    end

    def parse_hdd({:ok, %{body: xml}}) do
      {:ok, do_parse_hdd(xml, ~x"//hdd")}
    end

    defp do_parse_hdd(xml, path) do
      SweetXml.xpath(xml, path,
        id: ~x"./id/text()"i,
        hdd_name: ~x"./hddName/text()"s,
        hdd_path: ~x"./hddPath/text()"s,
        hdd_type: ~x"./hddType/text()"s,
        status: ~x"./status/text()"s,
        capacity: ~x"./capacity/text()"i,
        free_space: ~x"./freeSpace/text()"i,
        property: ~x"./property/text()"s
      )
    end

    def parse_channel_input_proxy_status({:ok, %{body: xml}}) do
      {:ok,
       SweetXml.xpath(xml, ~x"//InputProxyChannelStatus",
         id: ~x"./id/text()"i,
         online: ~x"./online/text()"s |> transform_by(&String.to_existing_atom/1),
         url: ~x"./url/text()"s,
         chan_detect_result: ~x"./chanDetectResult/text()"s,
         source_input_port_descriptor: [
           ~x"./sourceInputPortDescriptor",
           proxy_protocol: ~x"./proxyProtocol/text()"s,
           addressing_format_type: ~x"./addressingFormatType/text()"s,
           ip_address: ~x"./ipAddress/text()"s,
           manage_port_no: ~x"./managePortNo/text()"i,
           src_input_port: ~x"./srcInputPort/text()"i,
           user_name: ~x"./userName/text()"s,
           conn_mode: ~x"./connMode/text()"s,
           stream_type: ~x"./streamType/text()"s,
           device_id: ~x"./deviceID/text()"s
         ],
         streaming_proxy_channel_id:
           ~x"./streamingProxyChannelIdList/streamingProxyChannelId/text()"sl
       )}
    end

    # Streaming
    def parse_channels_config({:ok, %{body: xml}}) do
      {:ok, do_parse_channel_config(xml, ~x"//StreamingChannelList/StreamingChannel"l)}
    end

    def parse_channel_config({:ok, %{body: xml}}) do
      {:ok, do_parse_channel_config(xml, ~x"//StreamingChannel")}
    end

    defp do_parse_channel_config(body, path) do
      SweetXml.xpath(body, path,
        id: ~x"./id/text()"s,
        channel_name: ~x"./channelName/text()"s,
        enabled: ~x"./enabled/text()"s |> transform_by(&String.to_existing_atom/1),
        transport: [
          ~x"./Transport",
          max_packet_size: ~x"./maxPacketSize/text()"io,
          audio_packet_length: ~x"./audioPacketLength/text()"io,
          audio_inbound_packet_length: ~x"./audioInboundPacketLength/text()"io,
          audio_inbound_port_no: ~x"./audioInboundPortNo/text()"io,
          video_source_port_no: ~x"./videoSourcePortNo/text()"io,
          audio_source_port_no: ~x"./audioSourcePortNo/text()"io,
          streaming_transport:
            ~x"./ControlProtocolList/ControlProtocol/streamingTransport/text()"sl
        ],
        video: [
          ~x"./Video"o,
          enabled: ~x"./enabled/text()"s |> transform_by(&String.to_existing_atom/1),
          video_codec_type: ~x"./videoCodecType/text()"s,
          video_resolution_width: ~x"./videoResolutionWidth/text()"i,
          video_resolution_height: ~x"./videoResolutionHeight/text()"i,
          video_quality_control_type: ~x"./videoQualityControlType/text()"os,
          constant_bit_rate: ~x"./constantBitRate/text()"oi,
          vbr_upper_cap: ~x"./vbrUpperCap/text()"oi,
          vbr_lower_cap: ~x"./vbrLowerCap/text()"oi,
          max_frame_rate: ~x"./maxFrameRate/text()"i,
          key_frame_interval: ~x"./keyFrameInterval/text()"io,
          fixed_quality: ~x"./fixedQuality/text()"io,
          smart_codec:
            ~x"./SmartCodec/enabled/text()"so |> transform_by(&String.to_existing_atom/1)
        ]
      )
    end

    def parse_response_status({:ok, %{body: xml}}), do: {:ok, do_parse_response_status(xml)}

    def parse_response_status(%{body: xml}), do: do_parse_response_status(xml)

    defp do_parse_response_status(xml) do
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
