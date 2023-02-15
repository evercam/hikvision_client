defprotocol Hikvision.Operation do
  @doc """
  Serialize the operation into an XML request body
  """
  @spec serialize(t) :: String.t()
  def serialize(value)
end
