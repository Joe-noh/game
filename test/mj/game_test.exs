defmodule Mj.GameTest do
  use ExUnit.Case, async: true

  describe "start_new_game/1" do
    test "can start new game" do
      game_id = Mj.Game.generate_id()

      assert {:ok, pid} = Mj.Game.start_new_game(game_id)
      assert Process.alive?(pid)
    end

    test "cannot start with same id twice" do
      game_id = Mj.Game.generate_id()

      assert {:ok, pid} = Mj.Game.start_new_game(game_id)
      assert {:error, _} = Mj.Game.start_new_game(game_id)
    end
  end

  describe "add_player/2" do
    setup do
      game_id = Mj.Game.generate_id()
      {:ok, _pid} = Mj.Game.start_new_game(game_id)

      %{game_id: game_id}
    end

    test "can add four distinct players", %{game_id: game_id} do
      assert {:ok, 1} = Mj.Game.add_player(game_id, "player1")
      assert {:ok, 2} = Mj.Game.add_player(game_id, "player2")

      assert {:error, :already_joined} = Mj.Game.add_player(game_id, "player2")

      assert {:ok, 3} = Mj.Game.add_player(game_id, "player3")
      assert {:ok, 4} = Mj.Game.add_player(game_id, "player4")

      assert {:error, :full} = Mj.Game.add_player(game_id, "player5")
    end
  end
end
