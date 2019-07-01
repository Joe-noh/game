defmodule Mj.IdentitiesTest do
  use Mj.DataCase, async: true

  alias Mj.Identities

  describe "get_user!/1" do
    setup do
      {:ok, user} = Identities.create_user(%{name: "alice"})
      %{user: user}
    end

    test "returns a user", %{user: %{id: id, name: name}} do
      assert %{name: ^name} = Identities.get_user!(id)
    end

    test "raise if user does not exist" do
      assert_raise Ecto.NoResultsError, fn -> Identities.get_user!(0) end
    end
  end

  describe "create_user/1" do
    test "with valid data creates a user" do
      assert {:ok, user} = Identities.create_user(%{name: "john"})
      assert user.name == "john"
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Identities.create_user(%{})
    end

    test "cannot create the same name users" do
      assert {:ok, user} = Identities.create_user(%{name: "john"})
      assert {:error, changeset} = Identities.create_user(%{name: "john"})

      assert changeset.errors |> Keyword.has_key?(:name)
    end
  end
end
