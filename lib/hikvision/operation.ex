defmodule Hikvision.Operation do
  @moduledoc false

  import Hikvision.Http.Utils

  alias Hikvision.Http.Client

  @type method :: :get | :put | :post | :delete | :head

  @type t :: %__MODULE__{
          http_method: method(),
          path: binary(),
          params: map(),
          headers: list(),
          body: iodata() | nil,
          parser: (term() -> term()),
          download_to: Path.t()
        }

  defstruct http_method: :get,
            path: nil,
            params: %{},
            headers: [],
            body: nil,
            parser: &Function.identity/1,
            download_to: nil

  def new(path, opts \\ []) do
    struct(%__MODULE__{path: path}, opts)
  end

  @doc """
  Performs an operation on a Hikvision device.
  """
  def perform(%__MODULE__{} = op, config) do
    url = build_url(op, config)

    with {:error, %{status: 401, headers: headers}} <-
           do_request(
             op.http_method,
             url,
             op.body,
             with_auth_header(op, config),
             op.parser,
             op.download_to
           ) do
      do_request(
        op.http_method,
        url,
        op.body,
        with_auth_header(op, config, headers),
        op.parser,
        op.download_to
      )
    end
  end

  defp do_request(http_method, url, body, headers, parser, download_to) do
    case Client.request(http_method, url, body, headers, download_to) do
      :ok ->
        :ok

      {:ok, %{status: status} = resp} when status in 200..299 ->
        {:ok, parser.(resp)}

      {:ok, %{status: 401} = resp} ->
        {:error, resp}

      {:ok, %{status: status} = resp} when status != 404 and status in 400..499 ->
        {:error, Hikvision.Parsers.parse_error(resp)}

      {:ok, %{status: status} = resp} when status >= 500 ->
        {:error, resp}

      {:error, error} ->
        {:error, error}
    end
  end
end
