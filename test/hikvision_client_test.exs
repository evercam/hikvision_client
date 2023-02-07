defmodule HikvisionClientTest do
  use ExUnit.Case, async: true

  import Plug.Conn

  @error_response """
  <?xml version="1.0" encoding="UTF-8"?>
  <ResponseStatus version="2.0" xmlns="http://www.hikvision.com/ver20/XMLSchema">
  <requestURL>/ISAPI/System/status</requestURL>
  <statusCode>4</statusCode>
  <statusString>Invalid Operation</statusString>
  <subStatusCode>methodNotAllowed</subStatusCode>
  </ResponseStatus>
  """

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "Streaming tests" do
    setup do
      image_data = <<10, 20, 15, 11, 17, 20>>
      %{image_data: image_data}
    end

    test "Get snapshot", %{bypass: bypass, image_data: data} do
      Bypass.expect_once(bypass, "GET", "/ISAPI/Streaming/channels/101/picture", fn conn ->
        resp(conn, 200, data)
      end)

      assert {:ok, ^data} = Hikvision.snapshot(hik_client(bypass.port), "101")
    end

    test "Get snapshot from NVR", %{bypass: bypass, image_data: data} do
      Bypass.expect_once(bypass, "GET", "/ISAPI/Streaming/channels/201/picture", fn %{
                                                                                      query_params:
                                                                                        params
                                                                                    } = conn ->
        assert params["videoResolutionWidth"] == "1280"
        assert params["videoResolutionHeight"] == "720"

        resp(conn, 200, data)
      end)

      assert {:ok, ^data} =
               Hikvision.snapshot(hik_client(bypass.port), "201", width: 1280, height: 720)
    end
  end

  describe "Error responses" do
    test "Wrong username/password", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        if get_req_header(conn, "authorization") != [] do
          resp(conn, 401, "Authentication Error")
        else
          conn
          |> put_resp_header(
            "www-authenticate",
            "Digest qop=\"auth\", realm=\"elixir\", nonce=\"11454546\""
          )
          |> resp(401, "Authentication Error")
        end
      end)

      assert {:error, :unauthorized} = Hikvision.system_status(hik_client(bypass.port))
    end

    test "Bad request", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        conn
        |> put_resp_content_type("application/xml")
        |> resp(400, @error_response)
      end)

      assert {:error,
              %{
                endpoint: "/ISAPI/System/status",
                status_code: 4,
                code: "methodNotAllowed",
                description: "Invalid Operation"
              }} = Hikvision.system_status(hik_client(bypass.port))
    end

    test "Internal server error", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn -> resp(conn, 500, "Some random error") end)
      assert {:error, :server_error} = Hikvision.system_status(hik_client(bypass.port))
    end

    test "Server not reachable", %{bypass: bypass} do
      Bypass.down(bypass)
      assert {:error, {:failed_connect, _}} = Hikvision.system_status(hik_client(bypass.port))
    end
  end

  defp hik_client(port), do: Hikvision.new_client("http://localhost:#{port}", "user", "pass")
end
