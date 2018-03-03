defmodule Karmel.Config do
  use Agent

  @type token :: String.t()

  @spec app_token() :: token()
  def app_token() do
    Agent.get(__MODULE__, fn x -> x.app_token end)
  end

  def start_link(_) do
    Agent.start_link(fn -> get_config() end, name: __MODULE__)
  end

  defp get_config() do
    %{
      app_token: System.get_env("KARMEL_APP_TOKEN") || Application.get_env(:karmel, :app_token)
    }
  end
end
