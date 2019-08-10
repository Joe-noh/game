defmodule Mah.Repo do
  use Ecto.Repo,
    otp_app: :mah,
    adapter: Ecto.Adapters.Postgres
end
