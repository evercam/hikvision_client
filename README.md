# HikvisionClient

HTTP client that talks to **Hikvision** Camera/NVR using **ISAPI**.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `hikvision_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hikvision_client, "~> 0.1.0"}
  ]
end
```

## Usage

Create a client
```elixir
client = Hikvision.new_client("192.168.1.100:8896", "username", "password")
```

And then call one of the endpoints
```elixir
{:ok, resp} = Hikvision.system_status(client)
```

A response example will be
```elixir
%{
  cpus: [
    %{
      description: "2616.00", 
      usage: 0
    }
  ],
  current_device_time: "2023-01-30T15:47:54-05:00",
  device_uptime: 56145,
  file_handles: nil,
  memory: [
    %{
      available: 62.160156, 
      description: "DDR Memory", 
      usage: 179.46875
    }
  ],
  status: ""
 }
```

The digest header is cached in the `Process` dictionnary using `Process.put/1` and fetched and injected in the next response. As the client is 
cheaper to create, it's not a problem to create multiple clients even one per **Process**.  

