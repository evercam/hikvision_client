defmodule Hikvision.Http.DigestHeaderBuilder do
  @moduledoc """
  Resolve digest header challenge.

  It doesnt' follow `RFC 7616` and only supports `md5` hashing algorithm
  """

  defstruct realm: nil,
            nonce: nil,
            cnonce: nil,
            qop: nil,
            nc: "00000001",
            method: nil,
            uri: nil,
            username: nil,
            password: nil,
            response: nil

  def new(auth_header, http_method, uri, username, password) do
    params = parse_header(auth_header)

    %__MODULE__{
      realm: params["realm"],
      nonce: params["nonce"],
      qop: params["qop"],
      cnonce: :crypto.strong_rand_bytes(32) |> Base.encode16(case: :lower),
      method: http_method,
      uri: uri,
      username: username,
      password: password
    }
  end

  def calculate(%__MODULE__{qop: qop, cnonce: cnonce, nonce: nonce, nc: nc} = builder) do
    a1 = hash([builder.username, ":", builder.realm, ":", builder.password])
    a2 = hash([String.upcase("#{builder.method}"), ":", builder.uri])

    [a1, nonce, nc, cnonce, qop, a2]
    |> Enum.join(":")
    |> hash()
    |> then(&%__MODULE__{builder | response: &1})
  end

  def build(%__MODULE__{} = builder) do
    builder
    |> Map.from_struct()
    |> Map.drop([:method, :password])
    |> Enum.map_join(", ", fn
      {key, value} when key in [:qop, :nc] -> "#{key}=#{value}"
      {key, value} -> "#{key}=\"#{value}\""
    end)
    |> then(&"Digest #{&1}")
  end

  defp parse_header(header) do
    ["Digest", params] = String.split(header, " ", parts: 2)

    params
    |> String.split(", ")
    |> Enum.map(fn param ->
      [key, value] = String.split(param, "=")
      {key, String.trim(value, "\"")}
    end)
    |> Map.new()
  end

  defp hash(value), do: :crypto.hash(:md5, value) |> Base.encode16(case: :lower)
end
