defmodule Karmel.Command do
  @typedoc "How many karma points to add/subtract for given user"
  @type karma :: {Karmel.Request.userid(), integer}

  @type karmas :: [karma]

  @type command :: :info | :reset | :version | {:update, karmas}

  @typedoc "Represents a bot command"
  @type t :: %__MODULE__{
    command: command(),
    request: Karmel.Request.t()
  }
  defstruct [:command, :request]
end
