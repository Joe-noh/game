defmodule Mah.Matching.ParticipationTableTest do
  use ExUnit.Case, async: false

  alias Mah.Matching.ParticipationTable

  describe "join" do
    setup do
      ParticipationTable.clear()
    end

    test "returns :joined on second time" do
      {:newgame, game_id} = ParticipationTable.join("p1")
      {:joined, ^game_id} = ParticipationTable.join("p1")
    end
  end
end
