defmodule MjWeb.SessionControllerTest do
  use MjWeb.ConnCase, async: true

  describe "create session" do
    setup do
      Fixtures.create(:user, %{name: "john", password: "password"})
      :ok
    end

    test "renders token when verification passed", %{conn: conn} do
      json =
        conn
        |> post(Routes.session_path(conn, :create), session: %{name: "john", password: "password"})
        |> json_response(201)

      assert %{"token" => _token} = json["data"]
    end

    test "renders errors when params are incorrect", %{conn: conn} do
      conn
      |> post(Routes.session_path(conn, :create), session: %{name: "john", password: "fooooo"})
      |> json_response(401)
    end
  end
end
