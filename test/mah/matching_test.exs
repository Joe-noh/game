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
end
