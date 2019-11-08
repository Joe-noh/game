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

  def spawn_or_join(player_id) do
    case find_table(player_id) do
      nil -> spawn_game(player_id)
      table -> join_game(table, player_id)
    end
  end

  defp spawn_game(first_player_id) do
    with {:ok, %{id: game_id}} <- create_table(public: true),
         {:ok, game} <- %Mah.Mahjong.Game{} |> Mah.Mahjong.Game.add_player(first_player_id),
         {:ok, _pid} <- Mah.GameStore.start(game_id, game),
         :ok <- ParticipationTable.add(first_player_id, game_id) do
      {:ok, game_id}
    end
  end

  defp join_game(_table = %{id: game_id}, player_id) do
    with :ok <- Mah.Game.add_player(game_id, player_id),
         :ok <- ParticipationTable.add(player_id, game_id) do
      {:ok, game_id}
    end
  end
end
