defmodule Mj.Game.Server.GameGameStateTest do
  use ExUnit.Case, async: true

  alias Mj.Game.Server.GameState

  describe "haipai/1" do
    setup do
      state = GameState.new("game-id")
      state = %GameState{state | players: ~w[p1 p2 p3 p4]}

      %{state: state}
    end

    test "returns error tuple without four players", %{state: state} do
      state = %GameState{state | players: Enum.slice(state.players, 0..2)}

      assert {:error, _} = GameState.haipai(state)
    end

    test "setup tiles", %{state: state} do
      {:ok, state} = GameState.haipai(state)

      assert state.tsumo_player == 0
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
end
