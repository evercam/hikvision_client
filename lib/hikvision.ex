defmodule Hikvision do
  @moduledoc File.read!("README.md")

  use Application

  alias Hikvision.Config

  @type error :: {:error, :unauthorized} | {:error, :server_error} | {:error, map()}
  @type success :: {:ok, map()}

  @doc """
  Send a request to the Hikvision device
  """
  @spec request(term(), Keyword.t()) :: success() | error()
  def request(operation, config \\ []),
    do: Hikvision.Operation.perform(operation, Config.new(config))

  @impl Application
  def start(_type, _args) do
    children = [
      {Hikvision.Auth, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Hikvision.Supervisor)
  end
end
