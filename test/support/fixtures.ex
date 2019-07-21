defmodule Fixtures do
  def create(resource) do
    create(resource, %{})
  end

  def create(resource, attrs) when is_list(attrs) do
    create(resource, Enum.into(attrs, %{}))
  end

  def create(:user, attrs) when is_map(attrs) do
    %{
      name: Faker.Internet.user_name()
    }
    |> Map.merge(attrs)
    |> Mj.Identities.create_user()
  end

  def create(resource, num, attrs \\ %{}) when is_integer(num) and num > 0 do
    resources =
      Enum.map(1..num, fn _ ->
        {:ok, resource} = create(resource, attrs)
        resource
      end)

    {:ok, resources}
  end
end
