defmodule Mah.Game.Server do
  use GenStateMachine, callback_mode: :handle_event_function
  require Logger

  alias Mah.Game.State

  def child_spec(id) do
    %{id: id, start: {__MODULE__, :start_link, [id]}}
  end

  def start_link(id) do
    Logger.info("Starting Game.Server (id: #{id})")
    GenStateMachine.start_link(__MODULE__, id, name: via_tuple(id))
  end

  def players(id) do
    {:ok, game} = GenStateMachine.call(via_tuple(id), :game_state)
    {:ok, State.players(game)}
  end

  def hands(id) do
    {:ok, game} = GenStateMachine.call(via_tuple(id), :game_state)
    {:ok, State.hands(game)}
  end

  def add_player(id, player_id) do
    GenStateMachine.call(via_tuple(id), {:add_player, player_id})
  end

  def player_ready(id, player_id) do
    GenStateMachine.call(via_tuple(id), {:player_ready, player_id})
  end

  def startable_with?(id, players) do
    GenStateMachine.call(via_tuple(id), {:startable_with?, players})
  end

  def start_game(id) do
    GenStateMachine.call(via_tuple(id), :start_game)
  end

  def dahai(id, player_id, hai) do
    GenStateMachine.call(via_tuple(id), {:dahai, player_id, hai})
  end

  def next_tsumo(id) do
    GenStateMachine.call(via_tuple(id), :next_tsumo)
  end

  def init(id) do
    Process.flag(:trap_exit, true)
    {:ok, :wait_for_players, State.new(id)}
  end

  def handle_event({:call, from}, :game_state, _, game) do
    {:keep_state_and_data, {:reply, from, {:ok, game}}}
  end

  def handle_event({:call, from}, {:add_player, player_id}, :wait_for_players, game) do
    case State.add_player(game, player_id) do
      error = {:error, _} ->
        {:keep_state_and_data, {:reply, from, error}}

      {:ok, game} ->
        {:keep_state, game, {:reply, from, {:ok, :waiting}}}
    end
  end

  def handle_event({:call, from}, {:add_player, _player_id}, _other, _game) do
    {:keep_state_and_data, {:reply, from, {:error, :full}}}
  end

  def handle_event({:call, from}, {:player_ready, player_id}, :wait_for_players, game) do
    case State.player_ready(game, player_id) do
      {:ok, game} ->
        if State.startable?(game) do
          {:next_state, :startable, game, {:reply, from, {:ok, :startable}}}
        else
          {:keep_state, game, {:reply, from, {:ok, :waiting}}}
        end

      error = {:error, _} ->
        {:keep_state_and_data, {:reply, from, error}}
    end
  end

  def handle_event({:call, from}, {:player_ready, _}, _other, _game) do
    {:keep_state_and_data, {:reply, from, {:error, :unacceptable}}}
  end

  def handle_event({:call, from}, {:startable_with?, players}, :startable, %{ready: ready}) do
    {:keep_state_and_data, {:reply, from, Enum.sort(ready) == Enum.sort(players)}}
  end

  def handle_event({:call, from}, {:startable_with?, _players}, _other, _game) do
    {:keep_state_and_data, {:reply, from, false}}
  end

  def handle_event({:call, from}, :start_game, :startable, game) do
    {:ok, game = %{tsumo_player: tsumo_player}} = State.haipai(game)
    {:ok, game = %{tsumohai: tsumohai}} = State.tsumo(game)
    reply = %{player: tsumo_player, tsumohai: tsumohai}

    {:next_state, :wait_for_dahai, game, {:reply, from, {:ok, reply}}}
  end

  def handle_event({:call, from}, :start_game, _other, _game) do
    {:keep_state_and_data, {:reply, from, {:error, :unstartable}}}
  end

  def handle_event({:call, from}, :next_tsumo, :tsumoban, game) do
    {:ok, game = %{tsumo_player: tsumo_player}} = State.proceed_tsumoban(game)
    {:ok, game = %{tsumohai: tsumohai}} = State.tsumo(game)
    reply = %{player: tsumo_player, tsumohai: tsumohai}

    {:next_state, :wait_for_dahai, game, {:reply, from, {:ok, reply}}}
  end

  def handle_event({:call, from}, :next_tsumo, _other, _game) do
    {:keep_state_and_data, {:reply, from, {:error, :unacceptable}}}
  end

  def handle_event({:call, from}, {:dahai, player_id, hai}, :wait_for_dahai, game) do
    case State.dahai(game, player_id, hai) do
      {:ok, game} ->
        reply = State.last_dahai(game, player_id)
        {:next_state, :tsumoban, game, {:reply, from, {:ok, reply}}}

      error = {:error, _reason} ->
        {:keep_state_and_data, {:reply, from, error}}
    end
  end

  def handle_event(:info, {:EXIT, _pid, :shutdown}, _state, _game) do
    :stop
  end

  def terminate(_reason, state, game = %{id: id}) do
    Logger.info("id: #{id} terminating. state: #{inspect(state)}, game: #{inspect(game)}")
    :ok
  end

  defp via_tuple(id) do
    {:via, Horde.Registry, {Mah.GameRegistry, id}}
  end
end
