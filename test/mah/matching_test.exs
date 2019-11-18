defmodule Mah.MatchingTest do
  use Mah.DataCase, async: false

  alias Mah.Matching

  describe "create_participation" do
    setup do
      {:ok, table} = Matching.create_table(%{})

      %{table: table}
    end

    test "can insert up to 4 records for 1 game", %{table: table} do
      Enum.each(1..4, fn _ ->
        {:ok, user} = Fixtures.create(:user)
        assert {:ok, _} = Matching.create_participation(table, user)
      end)

      {:ok, user} = Fixtures.create(:user)
      assert {:error, _} = Matching.create_participation(table, user)
    end

    test "table/user pairs are unique", %{table: table} do
      {:ok, user} = Fixtures.create(:user)

      assert {:ok, _} = Matching.create_participation(table, user)
      assert {:error, _} = Matching.create_participation(table, user)
    end
  end

  describe "find_participation" do
    setup do
      {:ok, user} = Fixtures.create(:user)
      {:ok, table} = Matching.create_table(%{})

      %{table: table, user: user}
    end

    test "returns the user's participation", %{table: table, user: user} do
      {:ok, _} = Matching.create_participation(table, user)
      participation = Matching.find_participation(user.id)

      assert participation.table_id == table.id
    end

    test "does not search from finished tables", %{table: table, user: user} do
      {:ok, _} = Matching.create_participation(table, user)
      {:ok, _} = Matching.change_table_status(table, :finished)

      assert nil == Matching.find_participation(user.id)
    end
  end

  describe "find_participatable_table" do
    setup do
      {:ok, table} = Matching.create_table(%{})

      %{table: table}
    end

    test "does not return table which is already full", %{table: table} do
      assert Matching.find_participatable_table() != nil

      Enum.each(1..4, fn _ ->
        {:ok, user} = Fixtures.create(:user)
        {:ok, _} = Matching.create_participation(table, user)
      end)

      assert Matching.find_participatable_table() == nil
    end

    test "does not search from finished tables", %{table: table} do
      {:ok, _} = Matching.change_table_status(table, :finished)

      assert Matching.find_participatable_table() == nil
    end
  end
end
