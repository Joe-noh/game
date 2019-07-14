defmodule Mj.Game.Server.StateTest do
  use ExUnit.Case, async: true

  alias Mj.Game.Server.State

  describe "haipai/1" do
    setup do
      state = State.new("game-id")
      state = %State{state | players: ~w[p1 p2 p3 p4]}

      %{state: state}
    end

    test "returns error tuple without four players", %{state: state} do
      state = %State{state | players: Enum.slice(state.players, 0..2)}

      assert {:error, _} = State.haipai(state)
    end

    test "setup tiles", %{state: state} do
      {:ok, state} = State.haipai(state)

      assert state.chicha in state.players
      assert state.chicha == state.tsumo_player
      assert length(state.yamahai) == 70
      assert length(state.rinshanhai) == 4
      assert length(state.wanpai) == 10

      Enum.each(state.hai, fn {_player, hand} ->
        assert hand.sutehai == []
        assert hand.furo == []
        assert length(hand.tehai) == 13
      end)

      all_tiles =
        List.flatten([
          state.yamahai,
          state.rinshanhai,
          state.wanpai,
          Enum.map(state.hai, fn {_, %{tehai: tehai}} -> tehai end)
        ])

      assert length(all_tiles) == 136
      assert length(all_tiles) == length(Enum.dedup(all_tiles))
    end
  end
end
