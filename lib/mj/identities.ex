defmodule Mj.Identities do
  alias Mj.Repo
  alias Mj.Identities.{User, PasswordIdentity, SocialAccount}

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

  def signup_with_firebase_payload(payload = %{"aud" => aud}) do
    with true <- valid_aud?(aud),
         {:ok, map} <- do_signup_with_firebase_payload(payload) do
      {:ok, map}
    else
      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  defp do_signup_with_firebase_payload(%{"name" => name, "firebase" => firebase}) do
    provider = get_in(firebase, ["sign_in_provider"])
    [uid | _] = get_in(firebase, ["identities", provider])
    changeset = User.changeset(%User{}, %{name: name})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, changeset)
    |> Ecto.Multi.run(:social_account, fn repo, %{user: user} ->
      user
      |> Ecto.build_assoc(:social_account)
      |> SocialAccount.changeset(%{uid: uid, provider: provider})
      |> repo.insert()
    end)
    |> Repo.transaction()
  end

  defp valid_aud?(aud) do
    Application.get_env(:mj, :firebase) |> Keyword.get(:aud) == aud
  end

  def verify_password(name, password) when is_binary(name) do
    User
    |> Repo.get_by(name: name)
    |> verify_password(password)
  end

  def verify_password(user = %User{}, password) do
    %PasswordIdentity{digest: digest} = Ecto.assoc(user, :password_identity) |> Repo.one()

    Argon2.verify_pass(password, digest) && user
  end

  def verify_password(_, _) do
    Argon2.no_user_verify()
  end
end
