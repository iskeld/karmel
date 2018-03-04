defmodule Karmel.Slack do
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
        {:ok, %Karmel.Request{user_id: user, channel_id: channel, text: text}}

      %{
        "channel" => channel,
        "type" => "message",
        "subtype" => "file_share",
        "file" => %{"initial_comment" => %{"comment" => text, "user" => user}}
      } ->
        {:ok, %Karmel.Request{user_id: user, channel_id: channel, text: text}}

      %{"channel" => channel, "text" => text, "type" => "message", "user" => user} ->
        result = %Karmel.Request{user_id: user, channel_id: channel, text: text}

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
end
