defmodule Karmel.Parser do
  @moduledoc """
  This module provides command parsing functions
  """

  @type karma :: {Karmel.Request.userid(), integer}

  @karma_regex ~R/<@(\w+)>:?\s*(-{2,6}|\+{2,6})/

  @doc """
  Parses the given `message` and returns its type.
  If the message is the points assignment returns the assignments.
  `my_id` is the bot id to distinguish whether the bot is mentioned.

  ## Examples
      
      iex> Karmel.Parser.parse("<@U001>: info", "U001")
      :info

      iex> Karmel.Parser.parse("congratulations <@U002> ++++", "U001")
      {:update, [{"U002", 3}]}
  """
  @spec parse(String.t(), Karmel.Request.userid()) :: :info | :reset | {:update, [karma]} | nil
  def parse(message, my_id) do
    cond do
      message =~ ~r/^\s*<@#{my_id}>:?\s*(?:info)?\s*$/ ->
        :info

      message =~ ~r/^\s*<@#{my_id}>(?::?\s*|\s+)reset\s*$/ ->
        :reset

      true ->
        case extract_karma(message) do
          [] -> nil
          karma -> {:update, karma}
        end
    end
  end

  @doc """
  Parses given `message` to extract point assignments
  """
  @spec extract_karma(String.t()) :: [karma]
  def extract_karma(message) do
    for [_match, user, karma] <- Regex.scan(@karma_regex, message), do: {user, karma_value(karma)}
  end

  defp karma_value("+" <> pluses), do: String.length(pluses)
  defp karma_value("-" <> minuses), do: -String.length(minuses)
end
