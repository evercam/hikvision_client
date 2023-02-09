defmodule Hikvision do
  @moduledoc File.read!("README.md")

  alias Hikvision.{Client, ContentManagement, Streaming, System}

  @type error :: {:error, :unauthorized} | {:error, :server_error} | {:error, map()}
  @type success :: {:ok, map()}

  @type channel :: integer()

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
  @spec new_client(Client.url(), String.t(), String.t(), Client.req_handler() | nil) :: Client.t()
  defdelegate new_client(host, username, password, handler \\ nil), to: Client, as: :new

  @doc """
  Get the system status of the Camera/NVR
  """
  @spec system_status(Client.t()) :: success() | error()
  defdelegate system_status(client), to: System, as: :status

  @doc """
  Get a picture from a live feed.

  The channel is ignored by ISAPI when the device is a **Camera**. Otherwise it must be supplied
  in the hundred format (e.g. `201` second channel, main stream. `102` first channel, sub stream)

  The following options can be supplied:
    * *width* - The width of the picture, it's only working with NVR
    * *height* - The height of the picture, it's only working with NVR
  """
  @spec snapshot(Client.t(), String.t(), Keyword.t()) :: binary() | error()
  defdelegate snapshot(client, channel, opts \\ []), to: Streaming

  @spec search_profile(Client.t()) :: success() | error()
  defdelegate search_profile(client), to: ContentManagement

  @doc """
  Search content in the device

  The following options can be supplied:
    * *start_time* - the start time of the search, defaults to today at midnight UTC
    * *end_time* - the end time of the search, default to the current time in UTC
    * *type* - where to search, it accepts the following values:
      - `:main_stream` - search in the video main stream of the channel
      - `:sub_stream` - search in the video sub stream of the channel
      - `:picture` - search in the pictures of the channel

      Default value is `main_stream`, any value that is not recognized is ignored and `:main_stream` is used.

  Note that we fetch all the records, means that we send the requests recursively until all the records are
  fetched. Hikvision will return only a subset of the records if there's too many to return at once.

  Consider updating `start_time` and `end_time` to have fewer results.
  """
  @spec content_search(Client.t(), channel(), Keyword.t()) :: success() | error()
  defdelegate content_search(client, channel, opts \\ []), to: ContentManagement, as: :search
end
