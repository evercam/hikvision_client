defmodule Hikvision.ContentManagement do
  @moduledoc false

  alias Hikvision.{Client, Operation}
  alias Hikvision.ContentManagement.{CMSearchDescription, Parser}

  def search_profile(client),
    do:
      Client.request(client, :get, "/ContentMgmt/search/profile", nil,
        parser: &Parser.parse_search_profile/1
      )

  def search(%CMSearchDescription{} = search_op, client) do
    do_search(client, search_op, {0, []})
  end

  def download(playback_uri, client, opts \\ []) do
    body =
      [
        "<downloadRequest version=\"1.0\" xmlns=\"http://www.isapi.org/ver20/XMLSchema\">",
        "<playbackURI>",
        playback_uri,
        "</playbackURI>",
        "</downloadRequest>"
      ]
      |> Enum.join()

    Client.request(client, :post, "/ContentMgmt/download", body, opts)
  end

  def do_search(client, search_op, {total, items}) do
    with {:ok, result} <-
           Client.request(client, :post, "/ContentMgmt/search", Operation.serialize(search_op),
             parser: &Parser.parse_content_search/1
           ) do
      result = %{result | items: items ++ result.items, total: total + result.total}

      if result.status == "MORE",
        do: do_search(client, search_op, {result.total, result.items}),
        else: {:ok, result}
    end
  end
end
