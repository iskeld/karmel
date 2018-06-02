ExUnit.start()
Code.load_file("test/util/test_bot.exs")
Ecto.Adapters.SQL.Sandbox.mode(Karmel.Repo, :manual)
Mox.defmock(Karmel.Test.Util.TestSlackApi, for: Karmel.Slack.Api)
