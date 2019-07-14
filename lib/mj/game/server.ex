defmodule Mj.Game.Server do
  require Logger

  defmodule State do
    defstruct id: nil,
              players: [],
              honba: 0,
              round: 1,
              chicha: nil,
              tsumo_player: nil,
              hai: %{},
              yamahai: [],
              rinshanhai: [],
              wanpai: []

    def new(id) do
      %__MODULE__{id: id}
    end

    def haipai(state) do
      if length(Enum.dedup(state.players)) == 4 do
        {:ok, do_haipai(state)}
      else
        {:error, :not_enough_players}
      end
    end

    defp do_haipai(state = %__MODULE__{players: players}) do
      %{chicha: chicha, tehai: tehai, yamahai: yamahai, rinshanhai: rinshanhai, wanpai: wanpai} = Mj.Mahjong.haipai(players, %{})
      hands = Enum.map(tehai, &%{tehai: &1, furo: [], sutehai: []})
      hai = state.players |> Enum.zip(hands) |> Enum.into(%{})

      %__MODULE__{state | chicha: chicha, tsumo_player: chicha, hai: hai, yamahai: yamahai, rinshanhai: rinshanhai, wanpai: wanpai}
    end
  end

  def child_spec(id) do
    %{id: id, start: {__MODULE__, :start_link, [id]}}
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
    {:ok, :wait_for_players, State.new(id)}
  end

  def callback_mode do
    :state_functions
  end

  def wait_for_players({:call, from}, {:add_player, player_id}, state = %{players: players}) do
    if player_id in players do
      {:keep_state_and_data, {:reply, from, {:error, :already_joined}}}
    else
      new_state = %State{state | players: [player_id | players]}

      if length(new_state.players) == 4 do
        {:keep_state, new_state, [{:reply, from, {:ok, 4}}, {:next_event, :internal, :start_game}]}
      else
        {:keep_state, new_state, {:reply, from, {:ok, length(new_state.players)}}}
      end
    end
  end

  def wait_for_players(:internal, :start_game, state = %{players: players}) do
    Enum.each(players, fn player ->
      MjWeb.Endpoint.broadcast!("user:#{player}", "game:start", %{players: players})
    end)

    {:ok, state} = State.haipai(state)

    {:next_state, :wait_for_players_ready, state}
  end

  def wait_for_players_ready({:call, from}, {:add_player, _}, _state) do
    {:keep_state_and_data, {:reply, from, {:error, :full}}}
  end

  def terminate(_reason, state = %{id: id}) do
    Logger.info("id: #{id} terminating. state: #{inspect(state)}")
    :ok
  end

  defp via_tuple(id) do
    {:via, Horde.Registry, {Mj.GameRegistry, id}}
  end
end
