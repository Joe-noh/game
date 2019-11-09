defmodule Mah.Matching.ParticipationTable do
  use GenServer

  @name {:global, __MODULE__}
  @initial_state %{player_to_game: %{}, game_players: %{}}

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def join(player_id) do
    GenServer.call(@name, {:join, player_id})
  end

  def clear do
    GenServer.call(@name, :clear)
  end

  def init(_) do
    {:ok, @initial_state}
  end

  def handle_call({:join, player_id}, _from, state = %{player_to_game: player_to_game, game_players: game_players}) do
    case Map.get(player_to_game, player_id) do
      nil ->
        case find_vacancy(game_players) do
          nil ->
            game_id = UUID.uuid4()
            next_state = %{
              player_to_game: player_to_game |> Map.put(player_id, game_id),
              game_players: game_players |> Map.update(game_id, [], fn players -> [player_id] end)
            }

            {:reply, {:newgame, game_id}, next_state}

          game_id ->
            next_state = %{
              player_to_game: player_to_game |> Map.put(player_id, game_id),
              game_players: game_players |> Map.update(game_id, [], fn players -> [player_id | players] end)
            }

            {:reply, {:joined, game_id}, next_state}
        end
      game_id ->
        {:reply, {:joined, game_id}, state}
    end
  end

  def handle_call(:clear, _from, _) do
    {:reply, :ok, @initial_state}
  end

  defp find_vacancy(game_players) do
    game_players
    |> Enum.find(fn {_game_id, players} -> length(players) < 4 end)
    |> case do
      {game_id, _players} -> game_id
      nil -> nil
    end
  end
end
