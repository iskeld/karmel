# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :karmel, ecto_repos: [Karmel.Repo]

config :karmel, app_token: "TEST_TOKEN"

config :karmel, bot: Karmel.BotImpl

config :karmel, slack_api: Karmel.Slack.Api.Http

import_config "#{Mix.env()}.exs"
