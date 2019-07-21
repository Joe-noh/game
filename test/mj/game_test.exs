defmodule Mj.GameTest do
  use ExUnit.Case, async: true

  describe "spawn_new_game/1" do
    test "can start new game" do
      assert {:ok, pid, _game_id} = Mj.Game.spawn_new_game()
      assert Process.alive?(pid)
    end
  end

  describe "add_player/2" do
    setup do
      {:ok, _pid, game_id} = Mj.Game.spawn_new_game()

      %{game_id: game_id}
    end

    test "can add four distinct players", %{game_id: game_id} do
      assert {:ok, :waiting} = Mj.Game.add_player(game_id, "player1")
      assert {:ok, :waiting} = Mj.Game.add_player(game_id, "player2")

      assert {:error, :already_joined} = Mj.Game.add_player(game_id, "player2")

      assert {:ok, :waiting} = Mj.Game.add_player(game_id, "player3")
      assert {:ok, :startable} = Mj.Game.add_player(game_id, "player4")

      assert {:error, :full} = Mj.Game.add_player(game_id, "player5")
    end
  end

  describe "start_game/1" do
    setup do
      {:ok, pid, game_id} = Mj.Game.spawn_new_game()

      %{game_id: game_id, pid: pid}
    end

    test "let the game start", %{game_id: game_id, pid: pid} do
      Mj.Game.add_player(game_id, "player1")
      Mj.Game.add_player(game_id, "player2")
      Mj.Game.add_player(game_id, "player3")
      Mj.Game.add_player(game_id, "player4")

      Mj.Game.start_game(game_id)

      assert {:wait_for_dahai, _game} = :sys.get_state(pid)
    end

    test "cannot start if the game is not startable", %{game_id: game_id, pid: pid} do
      Mj.Game.add_player(game_id, "player1")
      Mj.Game.add_player(game_id, "player2")
      Mj.Game.add_player(game_id, "player3")

      Mj.Game.start_game(game_id)

      assert {:wait_for_players, _game} = :sys.get_state(pid)
    end
  end
end
