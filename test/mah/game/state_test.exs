defmodule Mah.Game.StateTest do
  use ExUnit.Case, async: true

  alias Mah.Game.State, as: GameState

  setup do
    state = GameState.new("game-id")
    state = %GameState{state | players: ~w[p1 p2 p3 p4], ready: ~w[p1 p2 p3 p4]}

    %{state: state}
  end

  describe "add_player/2" do
    test "accepts players who have not joined yet", %{state: state} do
      state = %GameState{state | players: ~w[p1 p2 p3]}

      assert {:error, :already_joined} == GameState.add_player(state, "p3")
      assert {:ok, %GameState{}} = GameState.add_player(state, "p4")
    end
  end

  describe "startable?/1" do
    test "returns true if there were 4 players", %{state: state} do
      assert true == GameState.startable?(state)
    end

    test "returns false when there are not enough players", %{state: state} do
      assert false == GameState.startable?(%GameState{state | ready: ~w[p1 p2 p3]})
    end
  end

  describe "haipai/1" do
    test "returns error tuple without four players", %{state: state} do
      state = %GameState{state | players: Enum.slice(state.players, 0..2)}

      assert {:error, _} = GameState.haipai(state)
    end

    test "setup tiles", %{state: state} do
      {:ok, state} = GameState.haipai(state)

      assert state.tsumoban == state.players |> List.first()
      assert length(state.yamahai) == 70
      assert length(state.rinshanhai) == 4
      assert length(state.wanpai) == 10

      Enum.each(state.hands, fn {_player, hand} ->
        assert hand.sutehai == []
        assert hand.furo == []
        assert length(hand.tehai) == 13
      end)

      all_tiles =
        List.flatten([
          state.yamahai,
          state.rinshanhai,
          state.wanpai,
          Enum.map(state.hands, fn {_, %{tehai: tehai}} -> tehai end)
        ])

      assert length(all_tiles) == 136
      assert length(all_tiles) == length(Enum.dedup(all_tiles))
    end
  end

  describe "tsumo/1" do
    setup %{state: state} do
      {:ok, state} = GameState.haipai(state)

      %{state: state}
    end

    test "pick tsumohai from yamahai", %{state: state} do
      before = state.yamahai
      {:ok, state} = GameState.tsumo(state)

      refute state.tsumohai |> is_nil()
      assert length(state.yamahai) == length(before) - 1
    end
  end
end
