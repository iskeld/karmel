defmodule Karmel.Slack.Api.Http do
  @behaviour Karmel.Slack.Api

  defmodule Wrapper do
    use HTTPotion.Base

    def process_url(url) do
      "https://slack.com/api/" <> url
    end

    def request(method, url, options \\ []) do
      {token, new_options} = Keyword.pop(options, :token)

      updated_options = case token do
        nil ->
          new_options

        _ ->
          headers = get_json_headers(token)
          Keyword.update(new_options, :headers, headers, fn x -> Keyword.merge(x, headers) end)
      end

      super(method, url, updated_options)
    end

    defp get_json_headers(token) do
      [Authorization: "Bearer #{token}", "Content-Type": "application/json; charset=utf-8"]
    end
  end

  def auth_test(token) do
    Wrapper.post!("auth.test", token: token)
  end
end
