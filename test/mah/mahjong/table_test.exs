defmodule Mah.Mahjong.TableTest do
  use Mah.DataCase, async: true

  alias Mah.Repo
  alias Mah.Mahjong.Table

  describe "status" do
    setup do
      table = Table.changeset(%Table{}) |> Repo.insert!

      %{table: table}
    end

    test ":created by default", %{table: table} do
      assert table.status == Table.status(:created)
    end

    test "can save permitted values", %{table: table} do
      assert {:ok, _} = Table.changeset(table, %{status: Table.status(:started)}) |> Repo.update
      assert {:ok, _} = Table.changeset(table, %{status: Table.status(:finished)}) |> Repo.update
      assert {:error, _} = Table.changeset(table, %{status: 99999}) |> Repo.update
    end
  end
end
