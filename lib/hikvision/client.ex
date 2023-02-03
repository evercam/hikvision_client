defmodule Hikvision.Client do
  @moduledoc """
  HTTP client responsible for sending requests and parsing responses.
  """

  use DigexRequest

  alias Hikvision.Parsers

  import Hikvision.HTTP.Utils, only: [encode_query_params: 1]

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

  defstruct url: nil, username: nil, password: nil, prefix: "/ISAPI", handler: nil

  @doc """
  Create a new Hikvision http client

  Returns a new http client to use for subsequent requests. `handler` is a function that'll be invoked when
  a request needs to be sent. This is useful if the caller wants to use another `http client`.

  # Examples

  Create a new client:
  ```elixir
  client = Hikvision.Client.new("localhost:8888", "user", "pass")
  ```

  Create a client with custom handler:
  ```elixir
  def request(method, url, headers, body, opts) do
    # use an http client (Finch, Hackney, ...etc.) to make a request

    # return
    {:ok, %Response{}} or {:error, any}
  end

  client = Hikvision.Client.new("localhost:8888", "user", "pass", &request/5)
  ```
  """
  @spec new(url(), String.t(), String.t(), req_handler() | nil) :: Hikvision.Client.t()
  def new(url, username, password, handler \\ nil) do
    %__MODULE__{
      url: url,
      username: username,
      password: password,
      handler: handler
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
        Process.put(:digex_request, req)
        {:ok, parser_fn.(resp)}

      {:ok, %{status: status} = resp, req} when status in 400..499 ->
        Process.put(:digex_request, req)
        {:error, Parsers.parse_error(resp)}

      {:ok, _resp, _req} ->
        {:error, :server_error}

      other ->
        other
    end
  end

  defp get_or_create_digex_request(
         %__MODULE__{username: username, password: pass},
         method,
         url,
         query_params,
         headers,
         body
       ) do
    url = "#{url}?#{query_params}"

    case Process.get(:digex_request) do
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
    handler = Keyword.get(opts, :handler) || (&super/5)
    handler.(method, url, headers, body, Keyword.delete(opts, :handler))
  end
end
