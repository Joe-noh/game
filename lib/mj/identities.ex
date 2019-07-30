defmodule Mj.Identities do
  alias Mj.Repo
  alias Mj.Identities.{User, PasswordIdentity}

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def create_user(attrs \\ %{}) do
    {password, attrs} = Map.pop(attrs, "password")
    changeset = %User{} |> User.changeset(attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, changeset)
    |> Ecto.Multi.run(:password_identity, fn repo, %{user: user} ->
      user
      |> Ecto.build_assoc(:password_identity)
      |> PasswordIdentity.changeset(%{password: password})
      |> repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def verify_password(name, password) when is_binary(name) do
    User
    |> Repo.get_by(name: name)
    |> verify_password(password)
  end

  def verify_password(user = %User{}, password) do
    %PasswordIdentity{digest: digest} = Ecto.assoc(user, :password_identity) |> Repo.one()

    Argon2.verify_pass(password, digest)
  end

  def verify_password(_, _) do
    Argon2.no_user_verify()
  end
end
