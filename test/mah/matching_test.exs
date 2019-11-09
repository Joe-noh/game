defmodule Mah.MatchingTest do
  use Mah.DataCase, async: false

  alias Mah.Matching
  alias Mah.Matching.Table

  describe "spawn_or_join" do
    setup do
      Mah.Matching.ParticipationTable.clear()

      %{player_id: UUID.uuid4()}
    end

    test "spawn new game if no one created", %{player_id: player_id} do
      {:ok, game_id} = Matching.spawn_or_join(player_id)
      game = Mah.GameStore.get(game_id, & &1)

      assert [player_id] == game |> Map.get(:players) |> Map.keys()
    end

    test "join game if there is unstarted one", %{player_id: player_id} do
      first_player = UUID.uuid4()
      {:ok, game_id} = Matching.spawn_or_join(first_player)
      {:ok, ^game_id} = Matching.spawn_or_join(player_id)
      game = Mah.GameStore.get(game_id, & &1)

      ids = game |> Map.get(:players) |> Map.keys()

      assert length(ids) == 2
      assert first_player in ids
      assert player_id in ids
    end
  end
end
