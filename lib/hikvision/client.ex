defmodule Hikvision.Client do
  @moduledoc """
  HTTP client to send requests and parse responses.
  """

  use DigexRequest

  alias Hikvision.Parsers

  import Hikvision.HTTP.Utils,
    only: [encode_query_params: 1, headers_from_charlist: 1, headers_to_charlist: 1]

  @type method :: :get | :post | :put | :delete | :patch | :options | :head
  @type headers :: [{binary(), binary}]
  @type body :: binary() | iolist() | nil

  @type url :: binary()

  @type response :: %{
          :status => integer(),
          :headers => headers(),
          :body => body()
        }

  @type req_handler ::
          (method(), String.t(), headers(), body(), Keyword.t() ->
             {:ok, response()} | {:error, term()})

  @type t :: %__MODULE__{
          url: url(),
          username: String.t(),
          password: String.t(),
          prefix: String.t(),
          handler: req_handler()
        }

  @enforce_keys [:url, :username, :password, :_id]
  defstruct url: nil, username: nil, password: nil, prefix: "/ISAPI", handler: nil, _id: nil

  @spec new(url(), String.t(), String.t(), req_handler() | nil) :: Hikvision.Client.t()
  def new(url, username, password, handler \\ nil) do
    %__MODULE__{
      url: url,
      username: username,
      password: password,
      handler: handler,
      _id: UUID.uuid4()
    }
  end

  def request(%__MODULE__{} = client, method, endpoint, body \\ nil, opts \\ []) do
    parser_fn = Keyword.get(opts, :parser, fn %{body: body} -> body end)
    url = "#{client.url}#{client.prefix}#{endpoint}"
    query_params = encode_query_params(opts[:query_params])

    digex_req = get_or_create_digex_request(client, method, url, query_params, [], body)

    case request(digex_req, Keyword.put(opts, :handler, client.handler)) do
      {:ok, %{status: 401}, _req} ->
        {:error, :unauthorized}

      {:ok, %{status: status} = resp, req} when status in 200..299 ->
        Process.put(client._id, req)
        {:ok, parser_fn.(resp)}

      {:ok, %{status: status} = resp, req} when status in 400..499 ->
        Process.put(client._id, req)
        {:error, Parsers.parse_error(resp)}

      {:ok, _resp, _req} ->
        {:error, :server_error}

      other ->
        other
    end
  end

  defp get_or_create_digex_request(
         %__MODULE__{_id: id, username: username, password: pass},
         method,
         url,
         query_params,
         headers,
         body
       ) do
    url = "#{url}?#{query_params}"

    case Process.get(id) do
      nil ->
        DigexRequest.new(method, url, username, pass, headers, body)

      %DigexRequest{} = req ->
        %DigexRequest{req | url: url, headers: headers, body: body}

      other ->
        raise "expected a DigexRequest struct, found: #{inspect(other)}"
    end
  end

  @impl DigexRequest
  def handle_request(method, url, headers, body, opts) do
    if Keyword.has_key?(opts, :stream) do
      stream(method, url, headers, body, opts)
    else
      handler = Keyword.get(opts, :handler) || (&super/5)
      handler.(method, url, headers, body, Keyword.delete(opts, :handler))
    end
  end

  defp stream(method, url, headers, body, opts) do
    request =
      if method in ~w(post put patch delete)a,
        do: {to_charlist(url), headers_to_charlist(headers), '', body},
        else: {to_charlist(url), headers_to_charlist(headers)}

    case :httpc.request(method, request, [], stream: to_charlist(opts[:stream])) do
      {:ok, :saved_to_file} ->
        {:ok, %DigexRequest.Response{headers: [], status: 200}}

      {:ok, {{_, status, _}, headers, body}} ->
        {:ok,
         %DigexRequest.Response{
           status: status,
           headers: headers_from_charlist(headers),
           body: body
         }}

      {:error, error} ->
        {:error, error}
    end
  end
end
