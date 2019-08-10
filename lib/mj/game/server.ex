defmodule Mah.Game.Server do
  use GenStateMachine, callback_mode: :handle_event_function
  require Logger

  defmodule GameState do
    defstruct id: nil,
              players: [],
              honba: 0,
              round: 1,
              tsumo_player_index: 0,
              tsumohai: nil,
              hands: %{},
              yamahai: [],
              rinshanhai: [],
              wanpai: []

    def new(id) do
      %__MODULE__{id: id}
    end

    def haipai(game) do
      if length(Enum.dedup(game.players)) == 4 do
        {:ok, do_haipai(game)}
      else
        {:error, :not_enough_players}
      end
    end

    defp do_haipai(game = %__MODULE__{players: players}) do
      %{players: players, hands: hands, yamahai: yamahai, rinshanhai: rinshanhai, wanpai: wanpai} = Mah.Mahjong.haipai(players, %{})

      %__MODULE__{game | players: players, hands: hands, yamahai: yamahai, rinshanhai: rinshanhai, wanpai: wanpai}
    end

    def tsumo(game) do
      [tsumohai | yamahai] = game.yamahai

      {:ok, %__MODULE__{game | tsumohai: tsumohai, yamahai: yamahai}}
    end

    def tsumogiri(game = %__MODULE__{players: players, hands: hands, tsumo_player_index: tsumo_player_index, tsumohai: tsumohai}, player_id) do
      if player_id == players[tsumo_player_index] do
        hands =
          Map.update!(hands, player_id, fn hand = %{sutehai: sutehai} ->
            Map.put(hand, :sutehai, [%{hai: tsumohai, tsumogiri: true} | sutehai])
          end)

        # TODO: check can anyone furo

        next_tsumo_player_index = rem(tsumo_player_index + 1, length(players))
        game = %GameState{game | tsumohai: nil, tsumo_player_index: next_tsumo_player_index, hands: hands}

        {:ok, game}
      else
        {:error, :not_your_turn}
      end
    end

    def dahai(game = %__MODULE__{players: players, hands: hands, tsumo_player_index: tsumo_player_index, tsumohai: tsumohai}, player_id, dahai) do
      if player_id == players[tsumo_player_index] do
        if dahai in get_in(hands, [player_id, :tehai]) do
          hands =
            Map.update!(hands, player_id, fn hand = %{tehai: tehai, sutehai: sutehai} ->
              hand
              |> Map.put(:sutehai, [%{hai: dahai, tsumogiri: false} | sutehai])
              |> Map.put(:tehai, [tsumohai | Enum.reject(tehai, &(&1 == dahai))])
            end)

          next_tsumo_player_index = rem(tsumo_player_index + 1, length(players))
          game = %GameState{game | tsumohai: nil, tsumo_player_index: next_tsumo_player_index, hands: hands}

          {:ok, game}
        else
          {:error, :not_in_your_hand}
        end
      else
        {:error, :not_your_turn}
      end
    end
  end

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

  def start_game(id) do
    GenStateMachine.cast(via_tuple(id), :start_game)
  end

  def dahai(id, player_id, dahai) do
    GenStateMachine.call(via_tuple(id), {:dahai, player_id, dahai})
  end

  def init(id) do
    Process.flag(:trap_exit, true)
    {:ok, :wait_for_players, GameState.new(id)}
  end

  def handle_event({:call, from}, {:add_player, player_id}, :wait_for_players, game = %{players: players}) do
    if player_id in players do
      {:keep_state_and_data, {:reply, from, {:error, :already_joined}}}
    else
      game = %GameState{game | players: [player_id | players]}

      if length(game.players) == 4 do
        {:next_state, :startable, game, {:reply, from, {:ok, :startable}}}
      else
        {:keep_state, game, {:reply, from, {:ok, :waiting}}}
      end
    end
  end

  def handle_event({:call, from}, {:add_player, _player_id}, _other, game) do
    {:keep_state, game, {:reply, from, {:error, :full}}}
  end

  def handle_event(:cast, :start_game, :startable, game) do
    {:ok, game = %{players: players, hands: hands}} = GameState.haipai(game)

    Enum.each(players, fn player ->
      hand = Map.get(hands, player)
      MahWeb.GameEventPusher.game_start(player, %{players: players, hand: hand})
    end)

    {:next_state, :tsumoban, game, {:next_event, :internal, :tsumo}}
  end

  def handle_event(:cast, :start_game, _other, game) do
    {:keep_state, game}
  end

  def handle_event(:internal, :tsumo, :tsumoban, game = %{players: players, tsumo_player_index: tsumo_player_index}) do
    {tsumo_player, other_players} = List.pop_at(players, tsumo_player_index)
    {:ok, game = %{tsumohai: tsumohai, yamahai: _yamahai}} = GameState.tsumo(game)

    MahWeb.GameEventPusher.tsumo(tsumo_player, %{tsumohai: tsumohai, other_players: other_players})

    {:next_state, :wait_for_dahai, game}
  end

  def handle_event({:call, from}, {:dahai, player_id, dahai}, :wait_for_dahai, game = %{tsumohai: dahai}) do
    {:ok, game} = GameState.tsumogiri(game, player_id)

    {:next_state, :tsumoban, game, [{:reply, from, :ok}, {:next_event, :internal, :tsumo}]}
  end

  def handle_event({:call, from}, {:dahai, player_id, dahai}, :wait_for_dahai, game) do
    {:ok, game} = GameState.dahai(game, player_id, dahai)

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
