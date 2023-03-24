defmodule Hikvision.Operation do
  @moduledoc """
  Holds data necessary for an operation
  """

  import Hikvision.Http.Utils

  alias Hikvision.{Auth, Http.Client}

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

  @doc """
  Create a new operation
  """
  @spec new(binary(), Keyword.t()) :: t()
  def new(path, opts \\ []) do
    struct(%__MODULE__{path: path}, opts)
  end

  @doc """
  Performs an operation on a Hikvision device.
  """
  @spec perform(t(), Hikvision.Config.t()) :: Hikvision.success() | Hikvision.error()
  def perform(%__MODULE__{http_method: method} = op, %{http_options: options} = config) do
    url = build_url(op, config)

    full_headers =
      Auth.inject_auth_headers(method, url, op.headers, config.username, config.password)

    with {:error, %{status: 401, headers: headers}} <-
           do_request(method, url, op.body, full_headers, op.parser, op.download_to, options) do
      full_headers =
        Auth.inject_auth_headers(
          method,
          url,
          op.headers,
          config.username,
          config.password,
          headers
        )

      do_request(method, url, op.body, full_headers, op.parser, op.download_to, options)
    end
  end

  defp do_request(http_method, url, body, headers, parser, download_to, http_options) do
    case Client.request(http_method, url, body, headers, download_to, http_options) do
      :ok ->
        :ok

      {:ok, %{status: status}} = resp when status in 200..299 ->
        parser.(resp)

      {:ok, %{status: 401} = resp} ->
        {:error, resp}

      {:ok, %{status: status} = resp} ->
        if status == 404,
          do: {:error, :not_found},
          else: {:error, Hikvision.Parsers.parse_response_status(resp)}

      {:error, error} ->
        {:error, error}
    end
  end
end
