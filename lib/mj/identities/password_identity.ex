defmodule Mj.Identities.PasswordIdentity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "password_identities" do
    field :digest, :string
    field :password, :string, virtual: true

    belongs_to :user, Mj.Identities.User

    timestamps()
  end

  @doc false
  def changeset(password_identity, attrs) do
    password_identity
    |> cast(attrs, [:digest, :password])
    |> hash_password()
    |> validate_required([:digest])
  end

  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> changeset |> put_change(:digest, Argon2.hash_pwd_salt(password))
    end
  end
end
