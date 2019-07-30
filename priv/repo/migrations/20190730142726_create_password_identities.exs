defmodule Mj.Repo.Migrations.CreatePasswordIdentities do
  use Ecto.Migration

  def change do
    create table(:password_identities) do
      add :digest, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:password_identities, [:user_id],
             name: "password_identities_user_id_index"
           )
  end
end
