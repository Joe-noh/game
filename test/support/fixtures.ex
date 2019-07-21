defmodule Fixtures do
  def create(resource, attrs \\ %{})

  def create(resource, attrs) when is_list(attrs) do
    create(resource, Enum.into(attrs, %{}))
  end

  def create(:user, attrs) do
    %{
      name: Faker.Internet.user_name()
    }
    |> Map.merge(attrs)
    |> Mj.Identities.create_user()
  end

  def create_list(resource, num, attrs \\ %{}) do
    resources = Enum.map(1..num, fn _ ->
      {:ok, resource} = create(resource, attrs)
      resource
    end)

    {:ok, resources}
  end
end
