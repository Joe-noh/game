defmodule Mah.MatchingTest do
  use Mah.DataCase, async: true

  alias Mah.Matching
  alias Mah.Matching.Table

  describe "find_table" do
    setup do
      %{player_id: UUID.uuid4()}
    end

    test "pick up unstarted public table", %{player_id: player_id} do
      {:ok, _secret} = Matching.create_table(public: false)

      {:ok, table} = Matching.create_table(public: true)
      {:ok, _ustarted} = Matching.change_table_status(table, :started)

      {:ok, table} = Matching.create_table(public: true)
      picked = Matching.find_table(player_id)

      assert picked.id == table.id
    end

    test "returns nil if not found", %{player_id: player_id} do
      assert nil == Matching.find_table(player_id)
    end
  end

  describe "create_table" do
    test "initial status is :created" do
      {:ok, table} = Matching.create_table(public: true)

      assert table.public == true
      assert table.status == Table.status(:created)
    end
  end

  describe "change_table_status" do
    test "changes status" do
      {:ok, table} = Matching.create_table(public: true)
      {:ok, table} = Matching.change_table_status(table, :started)

      assert table.status == Table.status(:started)
    end
  end

  describe "spawn_or_join" do
    setup do
      %{player_id: UUID.uuid4()}
    end

    test "spawn new game if no one created", %{player_id: player_id} do
      {:ok, game_id} = Matching.spawn_or_join(player_id)
      {:ok, game} = Mah.GameStore.get(game_id)

      assert [player_id] == game |> Map.get(:players) |> Map.keys()
    end

    test "join game if there is unstarted one", %{player_id: player_id} do
      first_player = UUID.uuid4()
      {:ok, game_id} = Matching.spawn_or_join(first_player)
      {:ok, ^game_id} = Matching.spawn_or_join(player_id)
      {:ok, game} = Mah.GameStore.get(game_id)

      ids = game |> Map.get(:players) |> Map.keys()

      assert length(ids) == 2
      assert first_player in ids
      assert player_id in ids
    end
  end
end
