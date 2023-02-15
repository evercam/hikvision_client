defmodule Hikvision.ContentManagement.CMSearchDescription do
  @type t :: %__MODULE__{
          id: String.t(),
          track_id: integer(),
          start_time: DateTime.t(),
          end_time: DateTime.t(),
          offset: integer(),
          max_results: integer()
        }

  @type resource_type :: :main_stream | :sub_stream | :picture

  @enforce_keys [:id, :track_id, :start_time, :end_time]
  defstruct id: nil, track_id: nil, start_time: nil, end_time: nil, offset: 0, max_results: 64

  @doc """
  Create a new search description operation.

  The track id is calculated from the channel and the resource type. The resource type can be one of the following:
    * `:main_stream` - search in the video main stream of the channel
    * `:sub_stream` - search in the video sub stream of the channel
    * `:picture` - search in the picture resources of the channel

  Default value is `:main_stream`, any value that is not recognized is ignored and `:main_stream` is used.
  """
  @spec new(integer(), resource_type(), String.t()) :: t()
  def new(channel, resource_type \\ :main_stream, id \\ UUID.uuid4()) do
    track_id = channel * 100

    track_id =
      case resource_type do
        :sub_stream -> track_id + 2
        :picture -> track_id + 3
        _ -> track_id + 1
      end

    %__MODULE__{
      id: id,
      track_id: track_id,
      start_time: DateTime.new!(Date.utc_today(), Time.new!(0, 0, 0)),
      end_time: DateTime.utc_now()
    }
  end

  @doc """
  Set the start time of the searched search
  """
  @spec with_start_time(t(), DateTime.t()) :: t()
  def with_start_time(search_op, start_time), do: %__MODULE__{search_op | start_time: start_time}

  @doc """
  Set the end time of the searched resource
  """
  @spec with_end_time(t(), DateTime.t()) :: t()
  def with_end_time(search_op, start_time), do: %__MODULE__{search_op | end_time: start_time}
end

defimpl Hikvision.Operation, for: Hikvision.ContentManagement.CMSearchDescription do
  alias Hikvision.ContentManagement.CMSearchDescription

  def serialize(%CMSearchDescription{} = op) do
    [
      "<CMSearchDescription version=\"2.0\" xmlns=\"http://www.isapi.org/ver20/XMLSchema\">",
      "<searchID>",
      op.id,
      "</searchID>",
      "<trackIDList><trackID>",
      op.track_id,
      "</trackID></trackIDList>",
      "<timeSpanList><timeSpan>",
      "<startTime>",
      DateTime.to_iso8601(op.start_time),
      "</startTime>",
      "<endTime>",
      DateTime.to_iso8601(op.end_time),
      "</endTime>",
      "</timeSpan></timeSpanList>",
      "<searchResultPosition>",
      op.offset,
      "</searchResultPosition>",
      "<maxResults>",
      op.max_results,
      "</maxResults>",
      "</CMSearchDescription>"
    ]
    |> Enum.join()
  end
end
