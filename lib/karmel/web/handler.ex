defmodule Karmel.Web.Handler do
  require Logger
  import Plug.Conn

  @behaviour Plug

  def init(_), do: []

  def call(conn, _opts) do
    case conn.body_params do
      %{"type" => "url_verification"} ->
        handle_url_verification(conn, conn.body_params)

      %{"type" => "event_callback"} ->
        handle_event(conn.body_params)
        send_ok(conn)

      %Plug.Conn.Unfetched{} ->
        raise "Unfetched"

      _ ->
        Logger.warn("Unexpected or missing event type #{inspect(conn.body_params)}")
        send_ok(conn)
    end
  end

  defp send_ok(conn) do
    send_resp(conn, 200, "")
  end

  defp handle_event(evt) when is_map(evt) do
    case Karmel.Slack.parse_event(evt) do
      {:ok, request} ->
        nil
      :error ->
        Logger.warn("Malformed event #{inspect(evt)}")
        nil
    end
  end

  defp handle_url_verification(conn, %{"challenge" => challenge}) do
    response = URI.encode_query(%{"challenge" => challenge})

    conn
    |> put_resp_content_type("application/x-www-form-urlencoded")
    |> send_resp(200, response)
  end

  defp handle_url_verification(conn, _) do
    Logger.warn("missing challenge from #{inspect(conn.remote_ip)}")

    conn
    |> send_resp(401, "missing challenge")
    |> halt()
  end
end
