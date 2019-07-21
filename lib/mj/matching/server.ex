defmodule Mj.Matching.Server do
  use GenServer

  defmodule State do
    defstruct unstarted_games: []

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

  def handle_call({:start_or_join, player_id}, _from, state = %{unstarted_games: []}) do
    {:ok, pid, game_id} = Mj.Game.spawn_new_game()
    Mj.Game.add_player(game_id, player_id)

    ref = Process.monitor(pid)

    {:reply, {:ok, game_id}, %State{state | unstarted_games: [{game_id, ref}]}}
  end

  def handle_call({:start_or_join, player_id}, _from, state = %{unstarted_games: unstarted_games}) do
    [{game_id, ref} | rest] = unstarted_games

    case Mj.Game.add_player(game_id, player_id) do
      {:error, :full} ->
        {:reply, {:error, :full}, %State{state | unstarted_games: rest}}

      {:error, :already_joined} ->
        {:reply, {:error, :already_joined}, state}

      {:ok, :start_game} ->
        Process.demonitor(ref)
        {:reply, {:ok, game_id}, state}

      {:ok, :waiting} ->
        {:reply, {:ok, game_id}, state}
    end
  end
end
