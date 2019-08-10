defmodule Mah.Game.Server.GameGameStateTest do
  use ExUnit.Case, async: true

  alias Mah.Game.Server.GameState

  setup do
    state = GameState.new("game-id")
    state = %GameState{state | players: ~w[p1 p2 p3 p4]}

    %{state: state}
  end

  describe "haipai/1" do
    test "returns error tuple without four players", %{state: state} do
      state = %GameState{state | players: Enum.slice(state.players, 0..2)}

      assert {:error, _} = GameState.haipai(state)
    end

    test "setup tiles", %{state: state} do
      {:ok, state} = GameState.haipai(state)

      assert state.tsumo_player_index == 0
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
