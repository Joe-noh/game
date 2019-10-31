defmodule Mah.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:tables, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :integer, null: false

      timestamps()
    end
  end
end
