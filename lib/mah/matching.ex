defmodule Mah.Matching do
  @moduledoc """
  Provides game matching functionalities.
  """

  import Ecto.Query

  alias Mah.Repo
  alias Mah.Matching.Table

  def find_table(_condition \\ %{}) do
    created = Table.status(:created)

    Table
    |> where(public: true, status: ^created)
    |> order_by(asc: :inserted_at)
    |> Repo.one()
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
