defmodule Mah.Matching do
  @moduledoc """
  Provides game matching functionalities.
  """

  import Ecto.Query

  alias Mah.Repo
  alias Mah.Matching.{ParticipationTable, Participation, Table}

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

  def create_participation(table, user) do
    %Participation{}
    |> Participation.changeset(%{table_id: table.id, user_id: user.id})
    |> Repo.insert()
  end

  def spawn_or_join(player_id) do
    case ParticipationTable.join(player_id) do
      {:newgame, game_id} ->
        spawn_game(game_id, player_id)

      {:joined, game_id} ->
        join_game(game_id, player_id)
    end
  end

  defp spawn_game(game_id, first_player_id) do
    with {:ok, _pid} <- Mah.GameStore.start(game_id, Mah.Mahjong.Game.new()),
         :ok <- Mah.Game.add_player(game_id, first_player_id) do
      {:ok, game_id}
    end
  end

  defp join_game(game_id, player_id) do
    with :ok <- Mah.Game.add_player(game_id, player_id) do
      {:ok, game_id}
    end
  end
end
