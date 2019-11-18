defmodule Mah.Matching do
  @moduledoc """
  Provides game matching functionalities.
  """

  import Ecto.Query

  alias Mah.Repo
  alias Mah.Matching.{Participation, Table}

  def find_participatable_table do
    finished = Table.status(:finished)

    Table
    |> join(:left, [t], u in assoc(t, :players))
    |> group_by([t, u], t.id)
    |> having([t, u], count(u.id) < 4)
    |> where([t, u], t.status != ^finished)
    |> order_by([t, u], asc: t.inserted_at)
    |> Repo.one()
  end

  def create_table(attrs \\ %{}) do
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

  def find_participation(player_id) do
    finished = Table.status(:finished)

    Participation
    |> join(:left, [p], t in assoc(p, :table))
    |> where([p, t], p.user_id == ^player_id and t.status != ^finished)
    |> order_by([p, t], asc: p.inserted_at)
    |> Repo.one()
  end

  def create_participation(table, user) do
    %Participation{}
    |> Participation.changeset(%{table_id: table.id, user_id: user.id})
    |> Repo.insert()
  end

  def create_table_or_participate(user) do
    case find_participatable_table() do
      nil ->
        {:ok, table} = create_table()
        create_participation(table, user)

      table ->
        create_participation(table, user)
    end
  end

  def spawn_game(table = %Table{id: game_id}) do
    game = Mah.Mahjong.Game.new()
    players = Ecto.assoc(table, :players) |> Repo.all()

    with {:ok, _pid} <- Mah.GameStore.start(game_id, game) do
      Enum.each(players, fn player -> :ok = Mah.Game.add_player(game_id, player.id) end)

      {:ok, game_id}
    end
  end
end
