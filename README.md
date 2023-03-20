# Hikvision Client

HTTP client that talks to **Hikvision** Camera/NVR using **ISAPI**.

## Installation

The package can be installed by adding `hikvision_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hikvision_client, "~> 0.1.0"}
  ]
end
```

## Usage

Create an operation
```elixir
operation = Hikvision.System.status()
```

And then send the request
```elixir
config = [scheme: "http", host: "localhost", port: 8200, username: "user", password: "password"]
{:ok, resp} = Hikvision.request(op, config)
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

