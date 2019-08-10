defmodule Mah.Identities.SocialAccount do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "social_accounts" do
    field :uid, :string
    field :provider, :string

    belongs_to :user, Mah.Identities.User

    timestamps()
  end

  @doc false
  def changeset(social_account, attrs) do
    social_account
    |> cast(attrs, [:uid, :provider])
    |> validate_required([:uid, :provider])
    |> validate_inclusion(:provider, ~w[twitter.com])
    |> unique_constraint(:provider, name: "social_accounts_user_id_provider_index")
  end
end
