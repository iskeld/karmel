defmodule Karmel.Slack.Api.Http do
  @behaviour Karmel.Slack.Api

  defmodule Wrapper do
    use HTTPoison.Base

    def process_url(url) do
      "https://slack.com/api/" <> url
    end

    def process_request_headers(headers) do
      {token, new_headers} = Keyword.pop(headers, :token)

      case token do
        nil -> new_headers
        _ -> get_json_headers(token) ++ new_headers
      end
    end

    def process_response_body(body) do
      body |> Poison.decode!()
    end

    defp get_json_headers(token) do
      [Authorization: "Bearer #{token}", "Content-Type": "application/json; charset=utf-8"]
    end
  end

  def auth_test(token) do
    case Wrapper.post("auth.test", "", token: token) do
      {:ok, %HTTPoison.Response{body: body}} ->
        case body do
          %{"ok" => true} ->
            result =
              body
              |> Map.take(~w(team team_id url user user_id))
              |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

            {:ok, result}

          %{"ok" => false, "error" => err} ->
            {:error, err}

          _ ->
            {:error, "Malformed body"}
        end

      {:error, err} ->
        {:error, Exception.message(err)}
    end
  end
end
