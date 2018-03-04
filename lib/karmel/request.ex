defmodule Karmel.Request do
  @moduledoc """
  Defines a single structure, representing a request from Slack
  """

  @type teamid :: String.t()

  @type userid :: String.t()

  @type channelid :: String.t()

  @typedoc "Represents a slack thread timestamp or `nil` if the message is not from thread"
  @type threadid :: String.t() | nil

  @typedoc "Represents request from Slack"
  @type t :: %__MODULE__ {
    team_id: teamid(),
    user_id: userid(),
    channel_id: channelid(),
    thread_id: threadid(),
    text: String.t()
  }

  defstruct [:team_id, :user_id, :channel_id, :thread_id, :text]
end
