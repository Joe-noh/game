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

  @firebase_payload %{
    "name" => "風化させないbot",
    "picture" => "https =>//pbs.twimg.com/profile_images/986579596693794816/AVrTgv1h_normal.jpg",
    "iss" => "https =>//securetoken.google.com/mah-development",
    "aud" => "mah-development",
    "auth_time" => 1_565_347_634,
    "user_id" => "HDsoCmiNUrQzC6MxtpaljELDFQv1",
    "sub" => "HDsoCmiNUrQzC6MxtpaljELDFQv1",
    "iat" => 1_565_347_634,
    "exp" => 1_565_351_234,
    "firebase" => %{
      "identities" => %{
        "twitter.com" => ["275472173"]
      },
      "sign_in_provider" => "twitter.com"
    }
  }

  describe "signup_with_firebase_payload/1" do
    test "create user and social_account" do
      {:ok, %{user: user, social_account: social_account}} = Identities.signup_with_firebase_payload(@firebase_payload)

      assert user.name == "風化させないbot"
      assert social_account.uid == "275472173"
      assert social_account.provider == "twitter.com"
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
