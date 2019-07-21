defmodule MjWeb.StartGameTest do
  use MjWeb.IntegrationCase, async: false

  describe "starting game" do
    test "normal case", %{conn: conn} do
      {:ok, p1} = Mj.Identities.create_user(%{name: "p1"})
      {:ok, p2} = Mj.Identities.create_user(%{name: "p2"})
      {:ok, p3} = Mj.Identities.create_user(%{name: "p3"})
      {:ok, p4} = Mj.Identities.create_user(%{name: "p4"})

      conn1 = TestHelpers.login(conn, p1)
      conn2 = TestHelpers.login(conn, p2)
      conn3 = TestHelpers.login(conn, p3)
      conn4 = TestHelpers.login(conn, p4)

      assert %{"data" => %{"game_id" => game_id}} = conn1 |> post(Routes.participation_path(conn, :create)) |> json_response(201)
      assert %{"data" => %{"game_id" => ^game_id}} = conn2 |> post(Routes.participation_path(conn, :create)) |> json_response(201)
      assert %{"data" => %{"game_id" => ^game_id}} = conn3 |> post(Routes.participation_path(conn, :create)) |> json_response(201)
      assert %{"data" => %{"game_id" => ^game_id}} = conn4 |> post(Routes.participation_path(conn, :create)) |> json_response(201)
    end
  end
end
