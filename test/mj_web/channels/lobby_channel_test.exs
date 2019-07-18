defmodule MjWeb.LobbyChannelTest do
  use MjWeb.ChannelCase, async: true

  alias MjWeb.UserSocket

  describe "matching:start_or_join" do
    test "start a game with four players" do
      {:ok, _, socket1} = create_user("user1") |> join()
      {:ok, _, socket2} = create_user("user2") |> join()
      {:ok, _, socket3} = create_user("user3") |> join()
      {:ok, _, socket4} = create_user("user4") |> join()
      {:ok, _, socket5} = create_user("user5") |> join()

      assert_reply push(socket1, "matching:start_or_join", %{}), :ok, %{game_id: game_id}
      assert_reply push(socket2, "matching:start_or_join", %{}), :ok, %{game_id: ^game_id}
      assert_reply push(socket3, "matching:start_or_join", %{}), :ok, %{game_id: ^game_id}
      assert_reply push(socket4, "matching:start_or_join", %{}), :ok, %{game_id: ^game_id}
      refute_reply push(socket5, "matching:start_or_join", %{}), :ok, %{game_id: ^game_id}

      %{topic: "user:" <> id1} = assert_broadcast("game:start", %{players: _, hand: %{tehai: _, furo: [], sutehai: []}})
      %{topic: "user:" <> id2} = assert_broadcast("game:start", %{players: _})
      %{topic: "user:" <> id3} = assert_broadcast("game:start", %{players: _})
      %{topic: "user:" <> id4} = assert_broadcast("game:start", %{players: _})

      assert [id1, id2, id3, id4] |> Enum.uniq() |> length() == 4
    end
  end

  defp create_user(name) do
    {:ok, user} = Mj.Identities.create_user(%{name: name})
    user
  end

  defp join(user) do
    {:ok, token, _claims} = MjWeb.Guardian.encode_and_sign(user)
    {:ok, socket} = connect(UserSocket, %{"token" => token}, %{})

    subscribe_and_join(socket, "lobby", %{})
  end
end
