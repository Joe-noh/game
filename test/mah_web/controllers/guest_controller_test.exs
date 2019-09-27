defmodule MahWeb.GuestControllerTest do
  use MahWeb.ConnCase, async: true

  describe "create guest user" do
    test "renders token", %{conn: conn} do
      json =
        conn
        |> post(Routes.guest_path(conn, :create))
        |> json_response(201)

      assert %{"token" => _} = json["data"]
    end
  end
end
