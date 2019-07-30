defmodule Mj.Identities do
  alias Mj.Repo
  alias Mj.Identities.{User, PasswordIdentity}

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def create_user(attrs \\ %{}) do
    {password, attrs} = Map.pop(attrs, "password")
    changeset = %User{} |> User.changeset(attrs)

    Ecto.Multi.new
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
end
