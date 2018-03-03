# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :karmel, app_token: "TEST_TOKEN"

import_config "#{Mix.env()}.exs"
