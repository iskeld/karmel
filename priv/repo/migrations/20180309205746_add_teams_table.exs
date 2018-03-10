defmodule Karmel.Repo.Migrations.AddTeamTable do
  use Ecto.Migration

  def change do
    create table("teams") do
      add :token, :string, size: 63
      add :name, :string

      timestamps()
    end

    create unique_index(:teams, [:token])
  end
end
