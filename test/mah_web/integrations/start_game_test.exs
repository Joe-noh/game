defmodule MahWeb.StartGameTest do
  use MahWeb.IntegrationCase, async: false

  describe "starting game" do
    test "start, haipai then tsumo", %{conn: conn} do
      {:ok, [p1, p2, p3, p4]} = Fixtures.create(:user, 4)

      conn1 = TestHelpers.login(conn, p1)
      conn2 = TestHelpers.login(conn, p2)
      conn3 = TestHelpers.login(conn, p3)
      conn4 = TestHelpers.login(conn, p4)

      assert %{"data" => %{"game_id" => game_id}} = participate_game(conn1)
      assert %{"data" => %{"game_id" => ^game_id}} = participate_game(conn2)
      assert %{"data" => %{"game_id" => ^game_id}} = participate_game(conn3)
      assert %{"data" => %{"game_id" => ^game_id}} = participate_game(conn4)

      {:ok, _, socket1 = %{id: topic1}} = connect_socket(p1, game_id)
      {:ok, _, socket2 = %{id: topic2}} = connect_socket(p2, game_id)
      {:ok, _, socket3 = %{id: topic3}} = connect_socket(p3, game_id)
      {:ok, _, socket4 = %{id: topic4}} = connect_socket(p4, game_id)

      @endpoint.subscribe(topic1)
      @endpoint.subscribe(topic2)
      @endpoint.subscribe(topic3)
      @endpoint.subscribe(topic4)

      Phoenix.ChannelTest.push(socket1, "ready", %{})
      Phoenix.ChannelTest.push(socket2, "ready", %{})
      Phoenix.ChannelTest.push(socket3, "ready", %{})
      Phoenix.ChannelTest.push(socket4, "ready", %{})

      :timer.sleep(100)
      {:messages, messages} = :erlang.process_info(self(), :messages)

      %{payload: %{players: players = [chicha | except_chicha]}} =
        Enum.find(messages, fn
          %{event: "game:start"} -> true
          _else -> false
        end)

      assertions =
        messages
        |> Enum.map(fn
          %{event: "game:start", payload: payload} ->
            assert length(payload.hand.tehai) == 13
            assert payload.hand.sutehai == []
            assert payload.hand.furo == []
            assert payload.players == players

          %{event: "game:tsumo", topic: topic} ->
            assert topic == "user:#{chicha}"

          %{event: "game:tacha_tsumo", topic: topic} ->
            assert topic in Enum.map(except_chicha, &"user:#{&1}")

          _ ->
            nil
        end)
        |> Enum.filter(& &1)

      assert length(assertions) == 8
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
