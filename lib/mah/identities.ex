defmodule Mah.Identities do
  import Ecto.Query

  alias Mah.Repo
  alias Mah.Identities.{User, SocialAccount}

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def get_user_by(condition) do
    User
    |> where([u], ^condition)
    |> Repo.one()
  end

  def get_social_account_by(provider: provider, uid: uid) do
    SocialAccount
    |> where([s], s.provider == ^provider and s.uid == ^uid)
    |> Repo.one()
  end

  def create_user(attrs \\ %{}) do
    changeset = %User{} |> User.changeset(attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def signup_with_firebase_payload(payload = %{"aud" => aud}) do
    with true <- valid_aud?(aud),
         {:ok, map = %{user: _, social_account: _}} <- do_signup_with_firebase_payload(payload) do
      {:ok, map}
    else
      false -> :error
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  defp do_signup_with_firebase_payload(%{"name" => name, "firebase" => firebase}) do
    provider = get_in(firebase, ["sign_in_provider"])
    [uid | _] = get_in(firebase, ["identities", provider])

    case get_social_account_by(provider: provider, uid: uid) do
      nil ->
        changeset = User.changeset(%User{}, %{name: name})

        Ecto.Multi.new()
        |> Ecto.Multi.insert(:user, changeset)
        |> Ecto.Multi.run(:social_account, fn repo, %{user: user} ->
          user
          |> Ecto.build_assoc(:social_accounts)
          |> SocialAccount.changeset(%{uid: uid, provider: provider})
          |> repo.insert()
        end)
        |> Repo.transaction()

      social_account ->
        user = social_account |> Ecto.assoc(:user) |> Repo.one()
        {:ok, %{user: user, social_account: social_account}}
    end
  end

  defp valid_aud?(aud) do
    Application.get_env(:mah, :firebase) |> Keyword.get(:aud) == aud
  end
end
