defmodule MahWeb.UserSocketTest do
  use MahWeb.ChannelCase, async: true

  alias MahWeb.UserSocket

  describe "connect" do
    test "with authenticated user" do
      {:ok, user} = Fixtures.create(:user)
      {:ok, token, _claims} = MahWeb.Guardian.encode_and_sign(user)

      assert {:ok, _socket} = connect(UserSocket, %{"auth_token" => token}, %{})
    end

    test "will fail if token is missing" do
      assert :error == connect(UserSocket, %{"auth_token" => nil}, %{})
    end
  end
end
