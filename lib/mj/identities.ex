defmodule Mj.Identities do
  alias Mj.Repo
  alias Mj.Identities.User

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
