defmodule Mah.Mahjong.MatchingTest do
  use Mah.DataCase, async: true

  alias Mah.Matching

  describe "create_table" do
    test "initial status is :created" do
      {:ok, table} = Matching.create_table()

      assert table.public == true
      assert table.status == Matching.Table.status(:created)
    end
  end
end
