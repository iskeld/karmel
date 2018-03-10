defmodule Karmel.Repo.Migrations.AddScoresTable do
  use Ecto.Migration

  def change do
    create table("scores") do
      add :user_id, :string, size: 63
      add :team_id, references("teams", on_delete: :delete_all)
      add :score, :integer

      timestamps()
    end

    create index(:scores, [:team_id])
  end
end
