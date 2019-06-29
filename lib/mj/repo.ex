defmodule Mj.Repo do
  use Ecto.Repo,
    otp_app: :mj,
    adapter: Ecto.Adapters.Postgres
end
