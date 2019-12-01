defmodule MahWeb.GameControllerTest do
  use MahWeb.ConnCase, async: true

  describe "show game" do
    setup %{conn: conn} do
      {:ok, user} = Fixtures.create(:user, name: "john")
      {:ok, table} = Mah.Matching.create_table()
      {:ok, _participation} = Mah.Matching.create_participation(table, user)
      {:ok, _game_id} = Mah.Matching.spawn_game(table.id)

      conn = TestHelpers.Session.login(conn, user)

      %{conn: conn, user: user, table: table}
    end

    test "renders masked game", %{conn: conn, table: table} do
      json =
        conn
        |> get(Routes.game_path(conn, :show, table))
        |> json_response(200)

      assert %{"game" => _} = json["data"]
    end
  end
end
