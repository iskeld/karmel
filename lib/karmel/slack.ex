defmodule Karmel.Slack do
  @moduledoc """
  Provides utility functions to interact with Slack APIs
  """

  @doc """
  Tries to parse the body of Slack Event API request into `Karmel.Request.t()`.
  On success returns tuple `{:ok, request}`, otherwise returns `:error`.
  """
  @spec parse_event(map()) :: {:ok, Karmel.Request.t()} | :error
  def parse_event(%{"team_id" => team_id, "event" => event}) do
    case extract_event(event) do
      {:ok, data} ->
        {:ok, %{data | team_id: team_id}}

      :error ->
        :error
    end
  end

  def parse_event(_), do: :error

  @spec extract_event(map()) :: {:ok, Karmel.Request.t()} | :error
  defp extract_event(evt) when is_map(evt) do
    case evt do
      %{
        "channel" => channel,
        "type" => "message",
        "subtype" => "file_comment",
        "comment" => %{"comment" => text, "user" => user}
      } ->
        {:ok, request(user, channel, text)}

      %{
        "channel" => channel,
        "type" => "message",
        "subtype" => "file_share",
        "file" => %{"initial_comment" => %{"comment" => text, "user" => user}}
      } ->
        {:ok, request(user, channel, text)}

      %{"channel" => channel, "text" => text, "type" => "message", "user" => user} ->
        result = request(user, channel, text)

        if Map.has_key?(evt, "thread_ts") do
          {:ok, %{result | thread_id: evt["thread_ts"]}}
        else
          {:ok, result}
        end

      _ ->
        :error
    end
  end

  defp extract_event(_), do: :error

  @spec request(String.t(), String.t(), String.t()) :: Karmel.Request.t()
  defp request(user, channel, text) do
    %Karmel.Request{user_id: user, channel_id: channel, text: text, team_id: "todo"}
  end
end
