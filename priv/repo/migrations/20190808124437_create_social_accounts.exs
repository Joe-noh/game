defmodule Mah.Repo.Migrations.CreateSocialAccounts do
  use Ecto.Migration

  def change do
    create table(:social_accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :uid, :string, null: false
      add :provider, :string, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:social_accounts, [:user_id], name: "social_accounts_user_id_index")
    create unique_index(:social_accounts, [:user_id, :provider], name: "social_accounts_user_id_provider_index")
  end
end
