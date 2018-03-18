defmodule Karmel.Repo.Migrations.AddTeamTable do
  use Ecto.Migration

  def change do
    create table("teams") do
      add :team_id, :string, size: 15
      add :token, :string, size: 63
      add :name, :string

      timestamps()
    end

    create unique_index(:teams, [:team_id])
  end
end
