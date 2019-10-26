defmodule Mah.Mahjong.Game do
  alias Mah.Mahjong.Game

  @all_tile_ids 0..135

  @type player_id :: String.t()
  @type tile :: non_neg_integer()
  @type tiles :: list(tile())
  @type t :: %{
          rule: Game.Rule.t(),
          honba: non_neg_integer(),
          round: pos_integer(),
          tsumoban: player_id() | nil,
          players: %{required(player_id()) => Game.Player.t()},
          yamahai: tiles(),
          rinshanhai: tiles(),
          wanpai: tiles()
        }

  defstruct rule: %Game.Rule{},
            honba: 0,
            round: 1,
            tsumoban: nil,
            tsumohai: nil,
            players: %{},
            yamahai: [],
            rinshanhai: [],
            wanpai: []

  def new(rule = %Game.Rule{}) do
    %__MODULE__{rule: rule}
  end

  def add_player(game = %__MODULE__{rule: rule, players: players}, player_id) do
    cond do
      player_id in Map.keys(players) ->
        {:error, :already_joined}

      map_size(players) == rule.num_players ->
        {:error, :full}

      true ->
        players = Map.put(players, player_id, %Game.Player{})
        {:ok, %__MODULE__{game | players: players}}
    end
  end

  def startable?(%__MODULE__{players: players, rule: rule}) do
    map_size(players) == rule.num_players
  end

  def haipai(game) do
    if startable?(game) do
      {:ok, do_haipai(game)}
    else
      {:error, :not_enough_players}
    end
  end

  defp do_haipai(game = %__MODULE__{rule: rule, players: players}) do
    tiles = @all_tile_ids |> Enum.shuffle()

    {yamahai, tiles} = Enum.split(tiles, 70)
    {rinshanhai, tiles} = Enum.split(tiles, 4)
    {wanpai, tiles} = Enum.split(tiles, 10)

    # 席順 (東南西北)
    player_ids = [tsumoban | _] = Map.keys(players) |> Enum.shuffle()

    players =
      player_ids
      |> Enum.zip(Enum.chunk_every(tiles, 13))
      |> Enum.with_index()
      |> Enum.map(fn {{player_id, tehai}, index} ->
        player = Map.get(players, player_id)
        {:ok, player} = Game.Player.chakuseki(player, index, rule.initial_point)
        {:ok, player} = Game.Player.haipai(player, tehai)
        {player_id, player}
      end)
      |> Enum.into(%{})

    %__MODULE__{game | players: players, tsumoban: tsumoban, yamahai: yamahai, rinshanhai: rinshanhai, wanpai: wanpai}
  end

  def tsumo(%__MODULE__{yamahai: []}) do
    :error
  end

  def tsumo(game = %__MODULE__{players: players, tsumoban: tsumoban, yamahai: [tsumohai | yamahai]}) do
    player = Map.get(players, tsumoban)

    with {:ok, player} <- Game.Player.tsumo(player, tsumohai) do
      players = Map.update!(players, tsumoban, player)
      %__MODULE__{game | yamahai: yamahai, players: players}
    end
  end

  def dahai(game = %__MODULE__{players: players}, player_id, hai, reach \\ false) do
    player = Map.get(players, player_id)

    with {:ok, player} <- Game.Player.dahai(player, hai, reach: reach),
         {:ok, game} <- proceed_tsumoban(game) do
      %__MODULE__{game | players: Map.update!(players, player_id, player)}
    end
  end

  defp proceed_tsumoban(game = %__MODULE__{players: players, tsumoban: tsumoban}) do
    current = Map.get(players, tsumoban)
    next = rem(current + 1, map_size(players))
    {next_id, _} = Enum.find(players, fn {_, p} -> p.seki == next end)

    {:ok, %__MODULE__{game | tsumoban: next_id}}
  end
end
