defmodule Mah.Game.ServerTest do
  use ExUnit.Case, async: true

  alias Mah.Game.Server

  @game_id "game-id"

  setup do
    {:ok, _pid} = Server.start_link(@game_id)
    :ok
  end

  test "does not crash" do
    assert {:ok, :waiting} == Server.add_player(@game_id, "p1")
    assert {:ok, :waiting} == Server.add_player(@game_id, "p2")
    assert {:ok, :waiting} == Server.add_player(@game_id, "p3")
    assert {:error, :already_joined} == Server.add_player(@game_id, "p3")
    assert {:ok, :waiting} == Server.add_player(@game_id, "p4")

    assert {:error, :unstartable} = Server.start_game(@game_id)

    assert {:ok, :waiting} == Server.player_ready(@game_id, "p1")
    assert {:ok, :waiting} == Server.player_ready(@game_id, "p2")
    assert {:ok, :waiting} == Server.player_ready(@game_id, "p3")
    assert {:ok, :startable} == Server.player_ready(@game_id, "p4")

    assert {:ok, %{player: _, tsumohai: _}} = Server.start_game(@game_id)
  end
end
