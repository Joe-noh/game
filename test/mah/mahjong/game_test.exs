defmodule Mah.Mahjong.GameTest do
  use ExUnit.Case, async: true

  alias Mah.Mahjong.Game

  describe "startable?" do
    setup [:one_more_player]

    test "returns true if all players got together", context do
      %{game: game} = one_more_player(context)

      assert false == Game.startable?(game)
      {:ok, game} = Game.add_player(game, "p4")
      assert true == Game.startable?(game)
    end

    test "returns false if it already started", context do
      %{game: game} = startable_game(context)

      assert true == Game.startable?(game)
      game = %Game{game | started: true}
      assert false == Game.startable?(game)
    end
  end

  describe "participated?" do
    setup [:one_more_player]

    test "returns true when already in players", %{game: game} do
      assert true == Game.participated?(game, "p1")
    end

    test "returns false when not in players", %{game: game} do
      assert false == Game.participated?(game, "p4")
    end
  end

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

    test "does not return error on duplicate join", %{game: game} do
      assert {:ok, game} = Game.add_player(game, "p1")
      assert {:ok, game} == Game.add_player(game, "p1")
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

  defp one_more_player(_) do
    game = Game.new(%Game.Rule{num_players: 4})
    game = Enum.reduce(~w[p1 p2 p3], game, fn id, acc -> Game.add_player(acc, id) |> elem(1) end)

    %{game: game}
  end

  defp startable_game(_) do
    game = Game.new(%Game.Rule{num_players: 4})
    game = Enum.reduce(~w[p1 p2 p3 p4], game, fn id, acc -> Game.add_player(acc, id) |> elem(1) end)

    %{game: game}
  end
end
