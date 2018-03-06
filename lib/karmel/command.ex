defmodule Karmel.Command do
  @typedoc "How many karma points to add/subtract for given user"
  @type score :: {Karmel.Request.userid(), integer}

  @type update_cmd :: {:update, %{is_cheater: boolean(), scores: [score]}}

  @type command :: :info | :reset | :version | update_cmd()

  @typedoc "Represents a bot command"
  @type t :: %__MODULE__{
    command: command(),
    request: Karmel.Request.t()
  }
  defstruct [:command, :request]
end
