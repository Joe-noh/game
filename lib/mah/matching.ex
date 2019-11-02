defmodule Mah.Matching do
  @moduledoc """
  Provides game matching functionalities.
  """

  import Ecto.Query

  alias Mah.Repo
  alias Mah.Matching.{ParticipationTable, Table}

  def find_table(player_id, _condition \\ %{}) do
    case ParticipationTable.get(player_id) do
      nil ->
        created = Table.status(:created)

        Table
        |> where(public: true, status: ^created)
        |> order_by(asc: :inserted_at)
        |> Repo.one()

      game_id ->
        Repo.get(Table, game_id)
    end
  end

  def create_table(attrs) do
    attrs = Enum.into(attrs, %{})

    %Table{}
    |> Table.changeset(attrs)
    |> Repo.insert()
  end

  def change_table_status(table, status) do
    table
    |> Table.changeset(%{status: Table.status(status)})
    |> Repo.update()
  end
end
