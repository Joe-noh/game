defmodule Mj.Game.Server do
  require Logger

  defmodule GameState do
    defstruct id: nil,
              players: [],
              honba: 0,
              round: 1,
              tsumo_player: 0,
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

    {:next_state, :wait_for_players_ready, game}
  end

  def wait_for_players_ready({:call, from}, {:add_player, _}, _game) do
    {:keep_state_and_data, {:reply, from, {:error, :full}}}
  end

  def terminate(_reason, state, game = %{id: id}) do
    Logger.info("id: #{id} terminating. state: #{inspect(state)}, game: #{inspect(game)}")
    :ok
  end

  defp via_tuple(id) do
    {:via, Horde.Registry, {Mj.GameRegistry, id}}
  end
end
