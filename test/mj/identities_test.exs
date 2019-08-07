defmodule Mj.IdentitiesTest do
  use Mj.DataCase, async: true

  alias Mj.Identities

  describe "get_user!/1" do
    setup do
      {:ok, user} = Fixtures.create(:user)
      %{user: user}
    end

    test "returns a user", %{user: %{id: id, name: name}} do
      assert %{name: ^name} = Identities.get_user!(id)
    end

    test "raise if user does not exist" do
      assert_raise Ecto.NoResultsError, fn -> Identities.get_user!("fa1b53c8-4c70-4d30-bee6-560fb8891ef5") end
    end
  end

  describe "create_user/1" do
    test "with valid data creates a user" do
      assert {:ok, user} = Identities.create_user(%{"name" => "john", "password" => "str0ngp4ssw0rd"})
      assert user.name == "john"
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Identities.create_user(%{})
    end

    test "cannot create the same name users" do
      assert {:ok, user} = Identities.create_user(%{"name" => "john", "password" => "str0ngp4ssw0rd"})
      assert {:error, changeset} = Identities.create_user(%{"name" => "john", "password" => "str0ngp4ssw0rd"})

      assert changeset.errors |> Keyword.has_key?(:name)
    end
  end

  describe "verify_password/2" do
    setup do
      Fixtures.create(:user, %{"name" => "john", "password" => "str0ngp4ssw0rd"})
      :ok
    end

    test "returns true if name/password is correct" do
      assert %Identities.User{} = Identities.verify_password("john", "str0ngp4ssw0rd")
      assert false == Identities.verify_password("john", "wr0ngp4ssw0rd")
    end
  end
end
