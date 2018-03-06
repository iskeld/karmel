defmodule Karmel.CommandParser do
  require Logger

  @moduledoc """
  This module provides command parsing functions
  """

  @karma_regex ~R/<@(\w+)>:?\s*(-{2,6}|\+{2,6})/

  @doc """
  Parses the given `message` and returns its type.
  If the message is the points assignment returns the assignments.
  `my_id` is the bot id to distinguish whether the bot is mentioned.
  """
  @spec parse(Karmel.Request.t(), Karmel.Request.userid()) :: Karmel.Command.t() | nil
  def parse(request = %Karmel.Request{is_direct: true, text: text}, _) do
    cond do
      text =~ ~r/^\s*version\s*$/ ->
        :version

      true ->
        :info
    end
    |> to_result(request)
  end

  def parse(request = %Karmel.Request{text: text}, bot_id) do
    cond do
      text =~ ~r/^\s*<@#{bot_id}>:?\s*(?:info)?\s*$/ ->
        :info

      text =~ ~r/^\s*<@#{bot_id}>:?\s*(?:reset)?\s*$/ ->
        :reset

      true ->
        case extract_scores(text) do
          [] ->
            nil

          scores ->
            no_cheats = Enum.filter(scores, fn x -> is_not_cheater?(request.user_id, x) end)
            is_cheater = length(scores) != length(no_cheats)
            {:update, %{is_cheater: is_cheater, scores: no_cheats}}
        end
    end
    |> to_result(request)
  end

  def parse(req) do
    Logger.warn("Malformed request #{inspect(req)}")
    nil
  end

  @doc """
  Parses given `message` to extract point assignments
  """
  @spec extract_scores(String.t()) :: [Karmel.Command.score()]
  def extract_scores(message) do
    for [_match, user, score] <- Regex.scan(@karma_regex, message), do: {user, value(score)}
  end

  @spec value(String.t()) :: integer()
  defp value("+" <> pluses), do: String.length(pluses)
  defp value("-" <> minuses), do: -String.length(minuses)

  @spec is_not_cheater?(Karmel.Request.userid(), Karmel.Command.score()) :: boolean()
  defp is_not_cheater?(sending_user_id, {user, points}), do: sending_user_id != user or points < 0

  @spec to_result(Karmel.Command.command() | nil, Karmel.Request.t()) :: nil | Karmel.Command.t()
  defp to_result(nil, _request), do: nil
  defp to_result(command, request), do: %Karmel.Command{command: command, request: request}
end
