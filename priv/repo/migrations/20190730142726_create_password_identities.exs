defmodule Mj.Repo.Migrations.CreatePasswordIdentities do
  use Ecto.Migration

  def change do
    create table(:password_identities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :digest, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create unique_index(:password_identities, [:user_id], name: "password_identities_user_id_index")
  end
end
