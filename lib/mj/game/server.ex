defmodule Mj.Game.Server do
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
      %{players: players, hands: hands, yamahai: yamahai, rinshanhai: rinshanhai, wanpai: wanpai} = Mj.Mahjong.haipai(players, %{})

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

  def callback_mode do
    :state_functions
  end

  def start_link(id) do
    Logger.info("Starting Game.Server (id: #{id})")
    :gen_statem.start_link(via_tuple(id), __MODULE__, id, [])
  end

  def add_player(id, player_id) do
    :gen_statem.call(via_tuple(id), {:add_player, player_id})
  end

  def dahai(id, player_id, dahai) do
    :gen_statem.call(via_tuple(id), {:dahai, player_id, dahai})
  end

  def init(id) do
    Process.flag(:trap_exit, true)
    {:ok, :wait_for_players, GameState.new(id)}
  end

  def wait_for_players({:call, from}, {:add_player, player_id}, game = %{players: players}) do
    if player_id in players do
      {:keep_state_and_data, {:reply, from, {:error, :already_joined}}}
    else
      game = %GameState{game | players: [player_id | players]}

      if length(game.players) == 4 do
        {:keep_state, game, [{:reply, from, {:ok, :start_game}}, {:next_event, :internal, :start_game}]}
      else
        {:keep_state, game, {:reply, from, {:ok, :waiting}}}
      end
    end
  end

  def wait_for_players(:internal, :start_game, game) do
    {:ok, game = %{players: players, hands: hands}} = GameState.haipai(game)

    Enum.each(players, fn player ->
      hand = Map.get(hands, player)
      MjWeb.GameEventPusher.game_start(player, %{players: players, hand: hand})
    end)

    {:next_state, :tsumoban, game, {:next_event, :internal, :tsumo}}
  end

  def tsumoban(:internal, :tsumo, game = %{players: players, tsumo_player_index: tsumo_player_index}) do
    {tsumo_player, other_players} = List.pop_at(players, tsumo_player_index)
    {:ok, game = %{tsumohai: tsumohai, yamahai: _yamahai}} = GameState.tsumo(game)

    MjWeb.GameEventPusher.tsumo(tsumo_player, %{tsumohai: tsumohai, other_players: other_players})

    {:next_state, :wait_for_dahai, game}
  end

  def tsumoban({:call, from}, {:add_player, _}, _game) do
    {:keep_state_and_data, {:reply, from, {:error, :full}}}
  end

  def wait_for_dahai({:call, from}, {:add_player, _}, _game) do
    {:keep_state_and_data, {:reply, from, {:error, :full}}}
  end

  def wait_for_dahai({:call, from}, {:dahai, player_id, dahai}, game = %{tsumohai: dahai}) do
    {:ok, game} = GameState.tsumogiri(game, player_id)

    {:next_state, :tsumoban, game, [{:reply, from, :ok}, {:next_event, :internal, :tsumo}]}
  end

  def wait_for_dahai({:call, from}, {:dahai, player_id, dahai}, game) do
    {:ok, game} = GameState.dahai(game, player_id, dahai)

    {:next_state, :tsumoban, game, [{:reply, from, :ok}, {:next_event, :internal, :tsumo}]}
  end

  def terminate(_reason, state, game = %{id: id}) do
    Logger.info("id: #{id} terminating. state: #{inspect(state)}, game: #{inspect(game)}")
    :ok
  end

  defp via_tuple(id) do
    {:via, Horde.Registry, {Mj.GameRegistry, id}}
  end
end
