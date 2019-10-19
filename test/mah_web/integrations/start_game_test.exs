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

      [%{payload: %{players: players = [chicha | except_chicha]}} | _] = game_events("game:start")

      assertions =
        Enum.map(game_events(), fn
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

      [%{payload: %{tsumohai: tsumohai}, topic: topic = "user:" <> user_id}] = game_events("game:tsumo")

      [socket1, socket2, socket3, socket4]
      |> Enum.find(fn socket -> socket.id == topic end)
      |> Phoenix.ChannelTest.push("dahai", %{hai: tsumohai})

      Enum.each(game_events("game:dahai"), fn %{payload: payload} ->
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

  defp game_events(event \\ nil) do
    {:messages, messages} = :erlang.process_info(self(), :messages)

    messages
    |> Enum.filter(&is_map(&1))
    |> Enum.filter(fn map ->
      if event do
        Map.get(map, :event) == event
      else
        Map.get(map, :event) |> String.starts_with?("game:")
      end
    end)
  end
end
