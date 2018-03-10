defmodule Karmel.Score do
  use Ecto.Schema

  schema "scores" do
    field :user_id, :string
    field :score, :integer
    belongs_to :team, Karmel.Team

    timestamps()
  end
end
