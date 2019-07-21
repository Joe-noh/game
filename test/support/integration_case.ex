defmodule MjWeb.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ConnTest
      use Phoenix.ChannelTest
      alias MjWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint MjWeb.Endpoint
    end
  end

  setup tags do
    Application.stop(:mj)
    Application.start(:mj)

    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Mj.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Mj.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn() |> Plug.Conn.put_req_header("accept", "application/json")

    {:ok, conn: conn}
  end
end
