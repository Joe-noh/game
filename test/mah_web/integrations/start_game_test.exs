defmodule MahWeb.StartGameTest do
  use MahWeb.IntegrationCase, async: false

  describe "starting game" do
    test "start, haipai then tsumo", %{conn: conn} do
      {:ok, users} = Fixtures.create(:user, 4)

      [conn1, conn2, conn3, conn4] = TestHelpers.Session.login(conn, users)

      assert %{"data" => %{"game_id" => game_id}} = participate_game(conn1)
      assert %{"data" => %{"game_id" => ^game_id}} = participate_game(conn2)
      assert %{"data" => %{"game_id" => ^game_id}} = participate_game(conn3)
      assert %{"data" => %{"game_id" => ^game_id}} = participate_game(conn4)

      sockets = Enum.map(users, fn user ->
        {:ok, _, socket} = connect_socket(user, game_id)
        socket
      end)

      Enum.each(sockets, &@endpoint.subscribe(&1.id))
      Enum.each(sockets, fn socket ->
        Phoenix.ChannelTest.push(socket, "ready", %{})
      end)
      :timer.sleep(50)

      [%{payload: %{players: players = [chicha | except_chicha]}} | _] = TestHelpers.Game.events(self(), "game:start")

      assertions =
        Enum.map(TestHelpers.Game.events(self()), fn
          %{event: "game:start", payload: payload} ->
            assert length(payload.tehai) == 13
            assert payload.sutehai == []
            assert payload.furo == []
            assert payload.players == players

          %{event: "game:tsumo", topic: topic} ->
            assert topic == "user:#{chicha}"

          %{event: "game:tacha_tsumo", topic: topic} ->
            assert topic in Enum.map(except_chicha, &"user:#{&1}")
        end)

      assert length(assertions) == 8

      [%{payload: %{tsumohai: tsumohai}, topic: topic = "user:" <> user_id}] = TestHelpers.Game.events(self(), "game:tsumo")

      sockets
      |> Enum.find(fn socket -> socket.id == topic end)
      |> Phoenix.ChannelTest.push("dahai", %{hai: tsumohai})

      Enum.each(TestHelpers.Game.events(self(), "game:dahai"), fn %{payload: payload} ->
        assert Map.get(payload, :hai) == tsumohai
        assert Map.get(payload, :tsumogiri) == true
        assert Map.get(payload, :player) == user_id
      end)
    end
  end

  defp participate_game(conn) do
    conn
    |> post(Routes.participation_path(conn, :create))
    |> json_response(201)
  end

  defp connect_socket(player, game_id) do
    MahWeb.UserSocket
    |> Phoenix.ChannelTest.socket("user:#{player.id}", %{user_id: player.id})
    |> Phoenix.ChannelTest.subscribe_and_join(MahWeb.GameChannel, "game:#{game_id}")
  end
end
