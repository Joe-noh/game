# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Mah.Repo.insert!(%Mah.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Mah.Repo
alias Mah.Identities

Repo.transaction(fn ->
  {:ok, _} = Identities.create_user(%{name: "dummy1"})
  {:ok, _} = Identities.create_user(%{name: "dummy2"})
  {:ok, _} = Identities.create_user(%{name: "dummy3"})
  {:ok, _} = Identities.create_user(%{name: "dummy4"})
end)
