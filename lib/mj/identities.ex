defmodule Mj.Identities do
  alias Mj.Repo
  alias Mj.Identities.User

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
