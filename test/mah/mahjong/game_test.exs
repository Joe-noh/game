defmodule Mah.Mahjong.GameTest do
  use ExUnit.Case, async: true

  alias Mah.Mahjong.Game

  describe "add_player/2" do
    setup do
      %{game: Game.new(%Game.Rule{})}
    end

    test "returns ok tuple", %{game: game} do
      assert {:ok, game} = Game.add_player(game, "p1")
      assert {:ok, game} = Game.add_player(game, "p2")
      assert {:ok, game} = Game.add_player(game, "p3")
      assert {:ok, _} = Game.add_player(game, "p4")
    end

    test "return error on duplicate join", %{game: game} do
      assert {:ok, game} = Game.add_player(game, "p1")
      assert {:error, :already_joined} == Game.add_player(game, "p1")
    end

    test "return error if full member", %{game: game} do
      assert {:ok, game} = Game.add_player(game, "p1")
      assert {:ok, game} = Game.add_player(game, "p2")
      assert {:ok, game} = Game.add_player(game, "p3")
      assert {:ok, game} = Game.add_player(game, "p4")
      assert {:error, :full} == Game.add_player(game, "p5")
    end
  end

  describe "haipai/1" do
    setup [:startable_game]

    setup %{game: game} do
      {:ok, game} = Game.haipai(game)
      %{game: game}
    end

    test "set sekijun", %{game: game} do
      Enum.each(game.players, fn {_id, player} ->
        refute player.seki |> is_nil
        assert player.seki in 0..3
      end)
    end

    test "reset points", %{game: game} do
      Enum.each(game.players, fn {_id, player} ->
        assert player.point == game.rule.initial_point
      end)
    end

    test "reset game count", %{game: game} do
      assert game.honba == 0
      assert game.round == 1
    end

    test "reset tiles", %{game: game} do
      assert length(game.yamahai) == 70
      assert length(game.rinshanhai) == 4
      assert length(game.wanpai) == 10

      Enum.each(game.players, fn {_id, player} ->
        assert length(player.tehai) == 13
        assert player.tsumohai |> is_nil
        assert player.furo == []
        assert player.sutehai == []
      end)
    end

    test "set tsumoban player", %{game: game} do
      tsumoban = Map.get(game.players, game.tsumoban)

      assert tsumoban.seki == 0
    end
  end

  defp startable_game(_) do
    game = Game.new(%Game.Rule{})
    game = Enum.reduce(~w[p1 p2 p3 p4], game, fn id, acc -> Game.add_player(acc, id) |> elem(1) end)

    %{game: game}
  end
end
