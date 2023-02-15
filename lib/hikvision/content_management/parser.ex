defmodule Hikvision.ContentManagement.Parser do
  @moduledoc false

  import SweetXml, only: [sigil_x: 2]

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
end
