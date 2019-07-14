defmodule Mj.Game.Server do
  use GenServer
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
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  def add_player(id, player_id) do
    GenServer.call(via_tuple(id), {:add_player, player_id})
  end

  def start_game(id) do
    GenServer.call(via_tuple(id), :start_game)
  end

  def init(id) do
    Process.flag(:trap_exit, true)
    {:ok, State.new(id)}
  end

  def handle_call({:add_player, _}, _from, state = %{players: players}) when length(players) >= 4 do
    {:reply, {:error, :full}, state}
  end

  def handle_call({:add_player, player_id}, _from, state = %{players: players}) do
    if player_id in players do
      {:reply, {:error, :already_joined}, state}
    else
      new_players = [player_id | players]
      {:reply, {:ok, length(new_players)}, %State{state | players: new_players}}
    end
  end

  def handle_call(:start_game, _from, state = %{players: players}) do
    Enum.each(players, fn player ->
      MjWeb.Endpoint.broadcast!("user:#{player}", "game:start", %{players: players})
    end)

    {:ok, state} = State.haipai(state)

    {:reply, :ok, state}
  end

  def terminate(_reason, state = %{id: id}) do
    Logger.info("id: #{id} terminating. state: #{inspect(state)}")
    :ok
  end

  defp via_tuple(id) do
    {:via, Horde.Registry, {Mj.GameRegistry, id}}
  end
end
