defmodule Mj.Identities.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mj.Identities.SocialAccount

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :string

    has_one :password_identity, Mj.Identities.PasswordIdentity
    has_one :social_account, SocialAccount
    has_one :twitter_account, SocialAccount, where: [provider: "twitter.com"]

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
