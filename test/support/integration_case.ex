defmodule MahWeb.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ConnTest
      use Phoenix.ChannelTest
      alias MahWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint MahWeb.Endpoint
    end
  end

  setup tags do
    Application.stop(:mah)
    Application.start(:mah)

    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Mah.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Mah.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn() |> Plug.Conn.put_req_header("accept", "application/json")

    {:ok, conn: conn}
  end
end
