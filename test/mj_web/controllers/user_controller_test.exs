defmodule MjWeb.UserControllerTest do
  use MjWeb.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
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
