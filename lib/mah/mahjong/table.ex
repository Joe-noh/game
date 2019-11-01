defmodule Mah.Mahjong.Table do
  use Ecto.Schema
  import Ecto.Changeset

  @status_enum %{
    created: 0,
    started: 1,
    finished: 2
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tables" do
    field :status, :integer, default: Map.get(@status_enum, :created)
    field :public, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(table, attrs \\ %{}) do
    table
    |> cast(attrs, [:status, :public])
    |> validate_required([:status, :public])
    |> validate_inclusion(:status, Map.values(@status_enum))
  end

  def status(name) do
    Map.get(@status_enum, name)
  end
end
