defmodule Karmel.Team do
  use Ecto.Schema

  schema "teams" do
    field :token, :string
    field :name, :string

    has_many :scores, Karmel.Score, on_delete: :delete_all

    timestamps()
  end
end
