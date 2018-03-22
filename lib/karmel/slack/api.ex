defmodule Karmel.Slack.Api do
  @callback auth_test(token :: String.t()) :: {:ok, map()} | {:error, String.t()}
end
