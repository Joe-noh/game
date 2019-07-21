defmodule MjWeb.ParticipationControllerTest do
  use MjWeb.ConnCase, async: true

  describe "declare participation" do
    setup %{conn: conn} do
      {:ok, user} = Fixtures.create(:user)
      conn = TestHelpers.login(conn, user)

      %{conn: conn, user: user}
    end

    test "returns a game_id", %{conn: conn} do
      json =
        conn
        |> post(Routes.participation_path(conn, :create))
        |> json_response(201)

      assert %{"game_id" => _} = json["data"]
    end

    test "requires login", %{conn: conn} do
      conn
      |> TestHelpers.logout()
      |> post(Routes.participation_path(conn, :create))
      |> json_response(401)
    end
  end
end
