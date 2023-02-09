defmodule Hikvision.ContentManagement do
  @moduledoc false

  alias Hikvision.{Client, Operation, Parsers}
  alias Hikvision.Operation.CMSearchDescription

  def search_profile(client),
    do:
      Client.request(client, :get, "/ContentMgmt/search/profile", nil,
        parser: &Parsers.parse_search_profile/1
      )

  def search(client, channel, opts \\ []) do
    start_time =
      Keyword.get(opts, :start_time, DateTime.new!(Date.utc_today(), Time.new!(0, 0, 0)))

    end_time = Keyword.get(opts, :end_time, DateTime.utc_now())

    track_id =
      case Keyword.get(opts, :type) do
        :picture -> 3
        :sub_stream -> 2
        _ -> 1
      end

    search_op = CMSearchDescription.new(channel * 100 + track_id, start_time, end_time)
    do_search(client, search_op, {0, []})
  end

  def do_search(client, search_op, {total, items}) do
    with {:ok, result} <-
           Client.request(client, :post, "/ContentMgmt/search", Operation.serialize(search_op),
             parser: &Parsers.parse_content_search/1
           ) do
      result = %{result | items: items ++ result.items, total: total + result.total}

      if result.status == "MORE",
        do: do_search(client, search_op, {result.total, result.items}),
        else: {:ok, result}
    end
  end
end
