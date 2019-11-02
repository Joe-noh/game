defmodule Mah.Matching.ParticipationTableTest do
  use ExUnit.Case, async: true

  alias Mah.Matching.ParticipationTable

  describe "add" do
    test "stores player id and game id" do
      assert :ok == ParticipationTable.add("p1", "g1")
      assert "g1" == ParticipationTable.get("p1")
    end

    test "ignores duplicated add" do
      assert :ok == ParticipationTable.add("p1", "g1")
      assert :ok == ParticipationTable.add("p1", "g1")
      assert "g1" == ParticipationTable.get("p1")
    end

    test "returns :error if player already participated in another game" do
      assert :ok == ParticipationTable.add("p1", "g1")
      assert :error == ParticipationTable.add("p1", "g2")
    end
  end
end
