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
end
