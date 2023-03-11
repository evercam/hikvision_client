defmodule Hikvision do
  @moduledoc File.read!("README.md")

  @type error :: {:error, :unauthorized} | {:error, :server_error} | {:error, map()}
  @type success :: {:ok, map()}

  @type channel :: integer()

  @doc """
  Send a request to the Hikvision device
  """
  @spec request(term(), Keyword.t()) :: success() | error()
  def request(operation, config), do: Hikvision.Operation.perform(operation, config)
end
