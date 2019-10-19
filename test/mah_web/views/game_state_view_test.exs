defmodule MahWeb.GameStateViewTest do
  use MahWeb.ConnCase, async: true

  import Phoenix.View

  describe "show.json" do
    setup do
      players = ~w[p1 p2 p3 p4]
      game = Mah.Game.State.new("game-id")
      game = %Mah.Game.State{game | players: players, ready: players}
      {:ok, game} = Mah.Game.State.haipai(game)

      %{game: game, players: players}
    end

    test "serialize game state", %{game: game, players: players = [player | _]} do
      expect = %{
        id: "game-id",
        players: game.players,
        honba: 0,
        round: 1,
        tehai: Mah.Game.State.hands(game) |> Map.get(:tehai) |> Map.get(player),
        sutehai: players |> Enum.map(&{&1, []}) |> Enum.into(%{}),
        tsumoban: List.first(game.players),
        tsumohai: nil
      }

      assert expect == render(MahWeb.GameStateView, "show.json", %{player: player, game: game})
    end
  end
end
