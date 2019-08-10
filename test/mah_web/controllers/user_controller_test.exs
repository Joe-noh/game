defmodule MahWeb.UserControllerTest do
  use MahWeb.ConnCase, async: true

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
    test "renders user when data is valid", %{conn: _conn} do
      # TODO: test with mocks
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn
      |> post(Routes.user_path(conn, :create), user: %{})
      |> json_response(400)
    end
  end
end
