defmodule Mj.IdentitiesTest do
  use Mj.DataCase, async: true

  alias Mj.Identities

  describe "users" do
    test "create_user/1 with valid data creates a user" do
      assert {:ok, user} = Identities.create_user(%{name: "john"})
      assert user.name == "john"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Identities.create_user(%{})
    end
  end
end
