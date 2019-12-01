defmodule Mah.Matching.Participation do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "participations" do
    belongs_to :table, Mah.Matching.Table
    belongs_to :user, Mah.Identities.User

    timestamps()
  end

  @doc false
  def changeset(table, attrs \\ %{}) do
    table
    |> cast(attrs, [:table_id, :user_id])
    |> validate_required([:table_id, :user_id])
    |> validate_players_number()
    |> unique_constraint(:table_id, name: "participations_table_id_user_id_index")
  end

  defp validate_players_number(changeset) do
    table_id = get_field(changeset, :table_id)
    count = Mah.Repo.one(from p in __MODULE__, where: p.table_id == ^table_id, select: count())

    if count < 4 do
      changeset
    else
      add_error(changeset, :table_id, "the table is full")
    end
  end
end
