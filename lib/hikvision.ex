defmodule Hikvision do
  @moduledoc """
  """

  alias Hikvision.{Client, System}

  @type error :: {:error, term()}
  @type success :: {:ok, map(), Client.t()}

  @spec new_client(Client.host(), String.t(), String.t()) :: Client.t()
  defdelegate new_client(host, username, password), to: Client, as: :new

  @spec system_status(Client.t()) :: success() | error()
  defdelegate system_status(client), to: System, as: :status
end
