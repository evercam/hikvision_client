defmodule HikvisionClientTest do
  use ExUnit.Case, async: true

  import Plug.Conn
  import SweetXml, only: [sigil_x: 2]

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

      assert {:ok, ^data} = req(Hikvision.Streaming.snapshot("101"), bypass)
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
               req(Hikvision.Streaming.snapshot("201", width: 1280, height: 720), bypass)
    end
  end

  describe "Content management tests" do
    test "Search video footages", %{bypass: bypass} do
      start_time = ~U(2023-02-09 10:00:00Z)
      end_time = ~U(2023-02-09 12:00:00Z)

      Bypass.expect_once(bypass, "POST", "/ISAPI/ContentMgmt/search", fn conn ->
        {:ok, body, conn} = read_body(conn)
        id = SweetXml.xpath(body, ~x"//CMSearchDescription", id: ~x"./searchID/text()"s).id

        expected_body =
          File.read!("test/requests/content_search.xml")
          |> String.replace("\n", "")
          |> String.replace("@id", id)
          |> String.replace("@track_id", "101")
          |> String.replace("@start_time", DateTime.to_iso8601(start_time))
          |> String.replace("@end_time", DateTime.to_iso8601(end_time))

        assert expected_body == body

        conn
        |> put_resp_content_type("application/xml")
        |> resp(200, File.read!("test/responses/content_search.xml") |> String.replace("@id", id))
      end)

      expected_result =
        Jason.decode!(File.read!("test/expected_responses/content_search.json"), keys: :atoms)

      assert {:ok, ^expected_result} =
               req(
                 Hikvision.ContentManagement.search(1,
                   start_time: start_time,
                   end_time: end_time,
                   id: expected_result.id
                 ),
                 bypass
               )
    end

    test "Download video footage", %{bypass: bypass} do
      playback_uri =
        "rtsp://localhost:2034/Streaming/tracks/101/?starttime=20230215T000000Z&endtime=20230215T005800Z&name=000015&size=2048"

      dest_file = Path.join("test", "file.mp4")

      Bypass.expect_once(bypass, "POST", "/ISAPI/ContentMgmt/download", fn conn ->
        {:ok, body, conn} = read_body(conn)

        expected_body =
          File.read!("test/requests/content_download.xml")
          |> String.replace("\n", "")
          |> String.replace("@playbackURI", playback_uri)

        assert expected_body == body

        conn
        |> put_resp_content_type("video/mp4")
        |> put_resp_header("content-disposition", "attachment; filename=sample.mp4")
        |> send_file(200, "test/responses/video_sample")
      end)

      expected_result = File.read!("test/responses/video_sample")

      assert :ok = req(Hikvision.ContentManagement.download(playback_uri, dest_file), bypass)

      assert File.exists?(dest_file)
      assert expected_result == File.read!(dest_file)

      File.rm_rf!(dest_file)
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

      assert {:error, %{status: 401}} = req(Hikvision.System.status(), bypass)
    end

    test "Bad request", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        conn
        |> put_resp_content_type("application/xml")
        |> resp(400, File.read!("test/responses/error.xml"))
      end)

      assert {:error,
              %{
                endpoint: "/ISAPI/System/status",
                status_code: 4,
                code: "methodNotAllowed",
                description: "Invalid Operation"
              }} = req(Hikvision.System.status(), bypass)
    end

    test "Internal server error", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn -> resp(conn, 500, File.read!("test/responses/error.xml")) end)

      assert {:error, %{status_code: 4}} = req(Hikvision.System.status(), bypass)
    end

    test "Server not reachable", %{bypass: bypass} do
      Bypass.down(bypass)
      assert {:error, {:failed_connect, _}} = req(Hikvision.System.status(), bypass)
    end
  end

  def req(op, bypass) do
    Hikvision.request(op,
      host: "localhost",
      port: bypass.port,
      username: "user",
      password: "pass"
    )
  end
end
