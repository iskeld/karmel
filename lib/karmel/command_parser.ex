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
    command =
      cond do
        text =~ ~r/^\s*<@#{bot_id}>:?\s*(?:info)?\s*$/ ->
          :info

        text =~ ~r/^\s*<@#{bot_id}>:?\s*(?:reset)?\s*$/ ->
          :reset

        true ->
          case extract_karma(text) do
            [] -> nil
            karma -> {:update, karma}
          end
      end

    to_result(command, request)
  end

  def parse(req) do
    Logger.warn("Malformed request #{inspect(req)}")
    nil
  end

  @spec to_result(Karmel.Command.command() | nil, Karmel.Request.t()) :: nil | Karmel.Command.t()
  defp to_result(nil, request), do: nil
  defp to_result(command, request), do: %Karmel.Command{command: command, request: request}

  @doc """
  Parses given `message` to extract point assignments
  """
  @spec extract_karma(String.t()) :: Karmel.Command.karmas()
  def extract_karma(message) do
    for [_match, user, karma] <- Regex.scan(@karma_regex, message), do: {user, karma_value(karma)}
  end

  @spec karma_value(String.t()) :: integer()
  defp karma_value("+" <> pluses), do: String.length(pluses)
  defp karma_value("-" <> minuses), do: -String.length(minuses)

  @spec is_cheater?(Karmel.Request.userid(), Karmel.Command.karma()) :: boolean()
  defp is_cheater?(sending_user, {user, karma}), do: sending_user == user and karma > 0
end
