defmodule Hikvision.ContentManagement do
  @moduledoc false

  alias Hikvision.{Operation, Parsers}

  @spec search_profile() :: Operation.t()
  def search_profile() do
    Operation.new("/ISAPI/ContentMgmt/search/profile", parser: &Parsers.parse_search_profile/1)
  end

  @doc """
  Search content in the device

  It acceps the following options:
    * `id` - the search id, useful to do pagination. Default, a random uuid
    * `resource_type` - where to search for the content, it can be `stream`, `sub_stream` or `picture`. Defaults to `stream`
    * `start_time` - filter out content less than this time. Defaults to current datetime
    * `end_time` - filter out content after this time. Defaults to current datetime
    * `offset` - the offset to the search, defaults to 0
    * `limit` - the max number of items to return, defaults to 64
  """
  @spec search(integer(), Keyword.t()) :: Operation.t()
  def search(channel, opts \\ []) do
    Operation.new("/ISAPI/ContentMgmt/search",
      http_method: :post,
      body: content_search_body(channel, opts),
      parser: &Parsers.parse_content_search/1
    )
  end

  @doc """
  Download video footage.

  A playback URI must be supplied to download the resource, the URI can be obtained from
  the response of `Hikvision.ContentManagement.search/2` function
  """
  @spec download(binary(), Path.t()) :: Operation.t()
  def download(playback_uri, destination) do
    Operation.new("/ISAPI/ContentMgmt/download",
      http_method: :post,
      body: download_body(playback_uri),
      download_to: destination
    )
  end

  defp download_body(playback_uri) do
    [
      "<downloadRequest version=\"1.0\" xmlns=\"http://www.isapi.org/ver20/XMLSchema\">",
      "<playbackURI>",
      playback_uri,
      "</playbackURI>",
      "</downloadRequest>"
    ]
    |> Enum.join()
  end

  defp content_search_body(channel, opts) do
    [
      "<CMSearchDescription version=\"2.0\" xmlns=\"http://www.isapi.org/ver20/XMLSchema\">",
      "<searchID>",
      Keyword.get(opts, :id, UUID.uuid4()),
      "</searchID>",
      "<trackIDList><trackID>",
      track_id(channel, Keyword.get(opts, :resource_type, :stream)),
      "</trackID></trackIDList>",
      "<timeSpanList><timeSpan>",
      "<startTime>",
      DateTime.to_iso8601(Keyword.get(opts, :start_time, DateTime.utc_now())),
      "</startTime>",
      "<endTime>",
      DateTime.to_iso8601(Keyword.get(opts, :end_time, DateTime.utc_now())),
      "</endTime>",
      "</timeSpan></timeSpanList>",
      "<searchResultPosition>",
      opts[:offset] || 0,
      "</searchResultPosition>",
      "<maxResults>",
      opts[:limit] || 64,
      "</maxResults>",
      "</CMSearchDescription>"
    ]
    |> Enum.join()
  end

  defp track_id(channel, :stream), do: channel * 100 + 1
  defp track_id(channel, :sub_stream), do: channel * 100 + 2
  defp track_id(channel, :picture), do: channel * 100 + 3
end
