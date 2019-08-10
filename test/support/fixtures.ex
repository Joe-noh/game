defmodule Fixtures do
  def create(resource) do
    create(resource, %{})
  end

  def create(resource, attrs) when is_list(attrs) do
    create(resource, Enum.into(attrs, %{}))
  end

  def create(:user, attrs) when is_map(attrs) do
    defaults = %{
      name: Faker.Internet.user_name(),
      provider: "twitter.com",
      uid: Faker.random_between(100_000, 999_999) |> Integer.to_string()
    }

    %{name: name, provider: provider, uid: uid} = Map.merge(defaults, attrs)

    {:ok, %{user: user}} =
      Mah.Identities.signup_with_firebase_payload(%{
        "name" => name,
        "aud" => "mah-development",
        "firebase" => %{
          "identities" => %{
            provider => [uid]
          },
          "sign_in_provider" => provider
        }
      })

    {:ok, user}
  end

  def create(resource, num, attrs \\ %{}) when is_integer(num) and num > 0 do
    resources =
      Enum.map(1..num, fn _ ->
        {:ok, resource} = create(resource, attrs)
        resource
      end)

    {:ok, resources}
  end

  defp stringify_keys(attrs) do
    attrs
    |> Enum.map(fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), v}
      {k, v} when is_binary(k) -> {k, v}
    end)
    |> Enum.into(%{})
  end
end
