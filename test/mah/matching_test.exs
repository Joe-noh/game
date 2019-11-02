defmodule Mah.Mahjong.MatchingTest do
  use Mah.DataCase, async: true

  alias Mah.Matching
  alias Mah.Matching.Table

  describe "find_table" do
    test "pick up unstarted public table" do
      {:ok, _secret} = Matching.create_table(public: false)

      {:ok, table} = Matching.create_table(public: true)
      {:ok, _ustarted} = Matching.change_table_status(table, :started)

      {:ok, table} = Matching.create_table(public: true)
      picked = Matching.find_table()

      assert picked.id == table.id
    end

    test "returns nil if not found" do
      assert nil == Matching.find_table()
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
