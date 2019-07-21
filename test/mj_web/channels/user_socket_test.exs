defmodule MjWeb.UserSocketTest do
  use MjWeb.ChannelCase, async: true

  alias MjWeb.UserSocket

  describe "connect" do
    test "with authenticated user" do
      {:ok, user} = Fixtures.create(:user)
      {:ok, token, _claims} = MjWeb.Guardian.encode_and_sign(user)

      assert {:ok, _socket} = connect(UserSocket, %{"token" => token}, %{})
    end

    test "will fail if token is missing" do
      assert :error == connect(UserSocket, %{"token" => nil}, %{})
    end
  end
end
