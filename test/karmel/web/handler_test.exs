defmodule Karmel.Web.HandlerTest do
  alias Karmel.Web.Handler
  use ExUnit.Case, async: true
  use Plug.Test

  @url "/"

  test "returns challenge for url_verification" do
    challenge = "3eZbrw1aBm2rZgRNFdxV2595E9CY3gmdALWMmHkvFXO7tYXAYM8P"

    request = %{
      "type" => "url_verification",
      "challenge" => challenge
    }

    conn = conn(:post, @url, request) |> call()

    assert conn.state == :sent
    assert conn.status == 200

    assert get_resp_header(conn, "content-type") == [
             "application/x-www-form-urlencoded; charset=utf-8"
           ]

    assert conn.resp_body == "challenge=#{challenge}"
    refute conn.halted
  end

  test "returns 401 for url_verification without challenge" do
    request = %{"type" => "url_verification"}
    conn = conn(:post, @url, request) |> call()

    assert conn.state == :sent
    assert conn.status == 401
    assert conn.halted
  end

  test "raises for unfetched body" do
    conn = conn(:post, "/")

    assert_raise RuntimeError, "Unfetched", fn ->
      Handler.call(conn, [])
    end
  end

  test "returns 200 with empty response for other event types" do
    request = %{type: "event_callback"}
    conn = conn(:post, @url, request) |> call()

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == ""
    refute conn.halted
  end

  defp call(conn), do: Handler.call(conn, [])
end
