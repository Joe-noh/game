defmodule Mah.Matching.Server do
  use GenServer

  defmodule State do
    defstruct unstarted_games: [], game_id_dict: %{}

    def new do
      %__MODULE__{}
    end
  end

  @name {:global, __MODULE__}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def start_or_join(player_id) do
    GenServer.call(@name, {:start_or_join, player_id})
  end

  def init(_opts) do
    {:ok, State.new()}
  end

  def handle_call({:start_or_join, player_id}, _from, state = %{game_id_dict: game_id_dict}) do
    case Map.get(game_id_dict, player_id) do
      nil ->
        handle_start_or_join(player_id, state)

      game_id ->
        {:reply, {:ok, game_id}, state}
    end
  end

  defp handle_start_or_join(player_id, state = %{unstarted_games: [], game_id_dict: game_id_dict}) do
    {:ok, pid, game_id} = Mah.Game.spawn_new_game()
    {:ok, :waiting} = Mah.Game.add_player(game_id, player_id)

    ref = Process.monitor(pid)
    dict = Map.put(game_id_dict, player_id, game_id)

    {:reply, {:ok, game_id}, %State{state | unstarted_games: [{game_id, ref}], game_id_dict: dict}}
  end

  defp handle_start_or_join(player_id, state = %{unstarted_games: unstarted_games, game_id_dict: game_id_dict}) do
    [{game_id, ref} | rest] = unstarted_games

    case Mah.Game.add_player(game_id, player_id) do
      {:error, :full} ->
        {:reply, {:error, :full}, %State{state | unstarted_games: rest}}

      {:error, :already_joined} ->
        {:reply, {:error, :already_joined, game_id}, state}

      {:ok, :startable} ->
        Process.demonitor(ref)
        dict = Map.put(game_id_dict, player_id, game_id)
        {:reply, {:ok, game_id}, %State{state | game_id_dict: dict}}

      {:ok, :waiting} ->
        dict = Map.put(game_id_dict, player_id, game_id)
        {:reply, {:ok, game_id}, %State{state | game_id_dict: dict}}
    end
  end
end
