defmodule Mah.Repo.Migrations.CreateParticipations do
  use Ecto.Migration

  def change do
    create table(:participations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :table_id, references(:tables, on_delete: :delete_all, type: :binary_id), null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create unique_index(:participations, [:table_id, :user_id], name: "participations_table_id_user_id_index")
  end
end
