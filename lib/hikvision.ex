defmodule Hikvision do
  @moduledoc File.read!("README.md")

  alias Hikvision.Config

  @type error :: {:error, :unauthorized} | {:error, :server_error} | {:error, map()}
  @type success :: {:ok, map()}

  @doc """
  Send a request to the Hikvision device
  """
  @spec request(term(), Keyword.t()) :: success() | error()
  def request(operation, config \\ []), do: Hikvision.Operation.perform(operation, Config.new(config))
end
