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

  def add_player(id, player_id) do
    GenStateMachine.call(via_tuple(id), {:add_player, player_id})
  end

  def startable_with?(id, players) do
    GenStateMachine.call(via_tuple(id), {:startable_with?, players})
  end

  def start_game(id) do
    GenStateMachine.cast(via_tuple(id), :start_game)
  end

  def dahai(id, player_id, dahai) do
    GenStateMachine.call(via_tuple(id), {:dahai, player_id, dahai})
  end

  def init(id) do
    Process.flag(:trap_exit, true)
    {:ok, :wait_for_players, State.new(id)}
  end

  def handle_event({:call, from}, {:add_player, player_id}, :wait_for_players, game) do
    case State.add_player(game, player_id) do
      error = {:error, :already_joined} ->
        {:keep_state_and_data, {:reply, from, error}}

      {:ok, game} ->
        if State.startable?(game) do
          {:next_state, :startable, game, {:reply, from, {:ok, :startable}}}
        else
          {:keep_state, game, {:reply, from, {:ok, :waiting}}}
        end
    end
  end

  def handle_event({:call, from}, {:add_player, _player_id}, _other, _game) do
    {:keep_state_and_data, {:reply, from, {:error, :full}}}
  end

  def handle_event({:call, from}, {:startable_with?, players}, :startable, game) do
    {:keep_state_and_data, {:reply, from, Enum.sort(game.players) == Enum.sort(players)}}
  end

  def handle_event({:call, from}, {:startable_with?, _players}, _other, _game) do
    {:keep_state_and_data, {:reply, from, false}}
  end

  def handle_event(:cast, :start_game, :startable, game) do
    {:ok, game = %{players: players, hands: hands}} = State.haipai(game)

    Enum.each(players, fn player ->
      hand = Map.get(hands, player)
      MahWeb.GameEventPusher.game_start(player, %{players: players, hand: hand})
    end)

    {:next_state, :tsumoban, game, {:next_event, :internal, :tsumo}}
  end

  def handle_event(:cast, :start_game, _other, _game) do
    :keep_state_and_data
  end

  def handle_event(:internal, :tsumo, :tsumoban, game = %{players: players, tsumo_player_index: tsumo_player_index}) do
    {tsumo_player, other_players} = List.pop_at(players, tsumo_player_index)
    {:ok, game = %{tsumohai: tsumohai, yamahai: _yamahai}} = State.tsumo(game)

    MahWeb.GameEventPusher.tsumo(tsumo_player, %{tsumohai: tsumohai, other_players: other_players})

    {:next_state, :wait_for_dahai, game}
  end

  def handle_event({:call, from}, {:dahai, player_id, dahai}, :wait_for_dahai, game = %{tsumohai: dahai}) do
    {:ok, game} = State.tsumogiri(game, player_id)

    {:next_state, :tsumoban, game, [{:reply, from, :ok}, {:next_event, :internal, :tsumo}]}
  end

  def handle_event({:call, from}, {:dahai, player_id, dahai}, :wait_for_dahai, game) do
    {:ok, game} = State.dahai(game, player_id, dahai)

    {:next_state, :tsumoban, game, [{:reply, from, :ok}, {:next_event, :internal, :tsumo}]}
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
