defmodule Karmel.Slack.Api do
  @callback auth_test(token :: String.t()) ::
              {:ok,
               %{
                 team: String.t(),
                 team_id: String.t(),
                 url: String.t(),
                 user: String.t(),
                 user_id: String.t()
               }}
              | {:error, String.t()}
end
