defmodule Karmel.Team do
  alias Karmel.Repo
  import Ecto.Query
  use Ecto.Schema

  schema "teams" do
    field :team_id, :string
    field :token, :string
    field :name, :string

    has_many :scores, Karmel.Score, on_delete: :delete_all

    timestamps()
  end

  @spec get_by_team_id(String.t(), boolean()) :: Ecto.Schema.t() | nil | no_return()
  def get_by_team_id(team_id, with_scores) do
    query = case with_scores do
      true -> __MODULE__ |> preload(:scores)
      _ -> __MODULE__
    end
    Repo.get_by(query, team_id: team_id)
  end
end
