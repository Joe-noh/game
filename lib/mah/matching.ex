defmodule Mah.Matching do
  @moduledoc """
  Provides game matching functionalities.
  """

  import Ecto.Query

  alias Mah.Repo
  alias Mah.Matching.Table

  def find_table do
    created = Table.status(:created)

    Table
    |> where(public: true, status: ^created)
    |> order_by(asc: :inserted_at)
    |> Repo.one()
  end

  def create_table do
    %Table{}
    |> Table.changeset()
    |> Repo.insert()
  end
end
