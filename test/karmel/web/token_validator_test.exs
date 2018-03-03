defmodule Karmel.Web.TokenValidatorTest do
  alias Karmel.Web.TokenValidator
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule MyPlug do
    use Plug.Builder

    plug TokenValidator
    plug :passthrough

    defp passthrough(conn, _) do
      Plug.Conn.send_resp(conn, 200, "Passthrough")
    end
  end

  defp call(conn), do: MyPlug.call(conn, [])

  defp request(token) do
    %{"token" => token}
  end

  test "raises for unfetched body" do
    conn = conn(:post, "/")

    assert_raise RuntimeError, "Unfetched", fn ->
      TokenValidator.call(conn, "")
    end
  end

  test "returns 401 for invalid token" do
    conn =
      conn(:post, "/", request("foo"))
      |> call()

    assert conn.state == :sent
    assert conn.status == 401
    assert conn.halted
  end

  test "valid token" do
    body = request(Karmel.Config.app_token())

    conn =
      conn(:post, "/", body)
      |> call()

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Passthrough"
    refute conn.halted
  end
end
