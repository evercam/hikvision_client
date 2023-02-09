defprotocol Hikvision.Operation do
  @spec serialize(t) :: String.t()
  def serialize(value)
end

defmodule Hikvision.Operation.CMSearchDescription do
  @type t :: %__MODULE__{
          id: String.t(),
          track_id: integer(),
          start_time: DateTime.t(),
          end_time: DateTime.t(),
          offset: integer(),
          max_results: integer()
        }

  @enforce_keys [:id, :track_id, :start_time, :end_time]
  defstruct id: nil, track_id: nil, start_time: nil, end_time: nil, offset: 0, max_results: 64

  def new(track_id, start_time, end_time) do
    %__MODULE__{
      id: UUID.uuid4(),
      track_id: track_id,
      start_time: start_time,
      end_time: end_time
    }
  end
end

defimpl Hikvision.Operation, for: Hikvision.Operation.CMSearchDescription do
  alias Hikvision.Operation.CMSearchDescription

  def serialize(%CMSearchDescription{} = op) do
    """
    <CMSearchDescription version="2.0" xmlns="http://www.isapi.org/ver20/XMLSchema">
    <searchID>#{op.id}</searchID>
    <trackIDList><trackID>#{op.track_id}</trackID></trackIDList>
    <timeSpanList>
    <timeSpan>
    <startTime>#{DateTime.to_iso8601(op.start_time)}</startTime>
    <endTime>#{DateTime.to_iso8601(op.end_time)}</endTime>
    </timeSpan>
    </timeSpanList>
    <searchResultPosition>#{op.offset}</searchResultPosition>
    <maxResults>#{op.max_results}</maxResults>
    </CMSearchDescription>
    """
    |> String.replace("\n", "")
  end
end
