defmodule Mah.Game.State do
  @all_tile_ids 0..135

  defstruct id: nil,
            players: [],
            ready: [],
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

  # queries

  def players(%__MODULE__{players: players}), do: players

  def hands(%__MODULE__{hands: hands}), do: hands

  def last_dahai(%__MODULE__{hands: hands}, player_id) do
    hands |> get_in([player_id, :sutehai]) |> List.first()
  end

  # commands

  def add_player(game = %__MODULE__{players: players}, player_id) do
    cond do
      length(players) == 4 ->
        {:error, :full}

      player_id in players ->
        {:error, :already_joined}

      true ->
        {:ok, %__MODULE__{game | players: [player_id | players]}}
    end
  end

  def player_ready(game = %__MODULE__{players: players, ready: ready}, player_id) do
    if player_id in players do
      {:ok, %__MODULE__{game | ready: Enum.dedup([player_id | ready])}}
    else
      {:error, :not_joined}
    end
  end

  def startable?(%__MODULE__{players: players, ready: ready}) do
    length(players) == 4 && length(ready) == 4
  end

  def haipai(game) do
    if startable?(game) do
      {:ok, do_haipai(game)}
    else
      {:error, :not_enough_players}
    end
  end

  defp do_haipai(game = %__MODULE__{players: players}) do
    tiles = @all_tile_ids |> Enum.shuffle()

    {yamahai, tiles} = Enum.split(tiles, 70)
    {rinshanhai, tiles} = Enum.split(tiles, 4)
    {wanpai, tiles} = Enum.split(tiles, 10)

    # 席順 (東南西北)
    players = Enum.shuffle(players)

    hands =
      Enum.chunk_every(tiles, 13)
      |> Enum.zip(players)
      |> Enum.reduce(%{}, fn {tehai, player}, acc ->
        Map.put(acc, player, %{tehai: tehai, furo: [], sutehai: []})
      end)

    %__MODULE__{game | players: players, hands: hands, yamahai: yamahai, rinshanhai: rinshanhai, wanpai: wanpai}
  end

  def proceed_tsumoban(game = %__MODULE__{players: players, tsumo_player_index: tsumo_player_index}) do
    next_tsumo_player_index = rem(tsumo_player_index + 1, length(players))
    {:ok, %__MODULE__{game | tsumo_player_index: next_tsumo_player_index}}
  end

  def tsumo(game = %__MODULE__{yamahai: yamahai}) do
    [tsumohai | yamahai] = yamahai

    {:ok, %__MODULE__{game | tsumohai: tsumohai, yamahai: yamahai}}
  end

  def dahai(game = %__MODULE__{players: players, hands: hands, tsumo_player_index: tsumo_player_index, tsumohai: tsumohai}, player_id, hai) do
    if player_id == Enum.at(players, tsumo_player_index) do
      if hai in get_in(hands, [player_id, :tehai]) || hai == tsumohai do
        hands = update_hands(hands, player_id, hai, tsumohai)
        game = %__MODULE__{game | tsumohai: nil, hands: hands}

        {:ok, game}
      else
        {:error, :not_in_your_hand}
      end
    else
      {:error, :not_your_turn}
    end
  end

  defp update_hands(hands, player_id, dahai, tsumohai) do
    Map.update!(hands, player_id, fn hand = %{tehai: tehai, sutehai: sutehai} ->
      hand
      |> Map.put(:sutehai, [%{hai: dahai, tsumogiri: dahai == tsumohai} | sutehai])
      |> Map.put(:tehai, Enum.reject([tsumohai | tehai], &(&1 == dahai)))
    end)
  end
end
