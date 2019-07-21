defmodule MjWeb.UserControllerTest do
  use MjWeb.ConnCase, async: true

  describe "show user" do
    setup %{conn: conn} do
      {:ok, user} = Fixtures.create(:user, name: "john")
      conn = TestHelpers.login(conn, user)

      %{conn: conn, user: user}
    end

    test "renders user", %{conn: conn, user: user} do
      json =
        conn
        |> get(Routes.user_path(conn, :show, user))
        |> json_response(200)

      assert %{"name" => "john"} = json["data"]
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      json =
        conn
        |> post(Routes.user_path(conn, :create), user: %{name: "john"})
        |> json_response(201)

      assert %{"id" => id, "name" => "john"} = json["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      json =
        conn
        |> post(Routes.user_path(conn, :create), user: %{name: nil})
        |> json_response(422)

      assert json["errors"] |> Map.has_key?("name")
    end
  end
end
