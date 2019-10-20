defmodule Mah.Game.State do
  @all_tile_ids 0..135

  @type player :: String.t()
  @type tile :: non_neg_integer()
  @type t :: %{
    id: String.t() | nil,
    players: list(player()),
    ready: list(player()),
    honba: non_neg_integer(),
    round: pos_integer(),
    tsumoban: player() | nil,
    tsumohai: tile() | nil,
    points: %{required(player()) => list(integer())},
    tehai: %{required(player()) => list(tile())},
    furo: %{required(player()) => list(tile())},
    sutehai: %{required(player()) => list(%{hai: tile(), tsumogiri: bool()})},
    yamahai: list(tile()),
    rinshanhai: list(tile()),
    wanpai: list(tile())
  }

  defstruct id: nil,
            players: [],
            ready: [],
            honba: 0,
            round: 1,
            tsumoban: nil,
            tsumohai: nil,
            points: %{},
            tehai: %{},
            furo: %{},
            sutehai: %{},
            yamahai: [],
            rinshanhai: [],
            wanpai: []

  def new(id) do
    %__MODULE__{id: id}
  end

  # queries

  def players(%__MODULE__{players: players}), do: players

  def hands(%__MODULE__{tehai: tehai, furo: furo, sutehai: sutehai}), do: %{tehai: tehai, furo: furo, sutehai: sutehai}

  def last_dahai(%__MODULE__{sutehai: sutehai}, player_id) do
    sutehai |> Map.get(player_id) |> List.first()
  end

  # commands

  def add_player(game = %__MODULE__{players: players}, player_id) do
    cond do
      player_id in players ->
        {:error, :already_joined}

      length(players) == 4 ->
        {:error, :full}

      true ->
        {:ok, %__MODULE__{game | players: [player_id | players]}}
    end
  end

  def player_ready(game = %__MODULE__{players: players, ready: ready}, player_id) do
    if player_id in players do
      ready = Enum.uniq([player_id | ready])
      {:ok, %__MODULE__{game | ready: ready}}
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
    players = [tsumoban | _] = Enum.shuffle(players)

    tehai = players |> Enum.zip(Enum.chunk_every(tiles, 13)) |> Enum.into(%{})
    furo = sutehai = players |> Enum.reduce(%{}, &Map.put(&2, &1, []))
    points = players |> Enum.reduce(%{}, &Map.put(&2, &1, 25000))

    %__MODULE__{game | players: players, tsumoban: tsumoban, points: points, tehai: tehai, furo: furo, sutehai: sutehai, yamahai: yamahai, rinshanhai: rinshanhai, wanpai: wanpai}
  end

  def proceed_tsumoban(game = %__MODULE__{players: players, tsumoban: tsumoban}) do
    current_player_index = Enum.find_index(players, &(&1 == tsumoban))
    next_player_index = rem(current_player_index + 1, length(players))
    next_player = Enum.at(players, next_player_index)

    {:ok, %__MODULE__{game | tsumoban: next_player}}
  end

  def tsumo(game = %__MODULE__{yamahai: yamahai}) do
    [tsumohai | yamahai] = yamahai

    {:ok, %__MODULE__{game | tsumohai: tsumohai, yamahai: yamahai}}
  end

  def dahai(%__MODULE__{tsumoban: tsumoban}, player_id, _hai) when tsumoban != player_id do
    {:error, :not_your_turn}
  end

  def dahai(game = %__MODULE__{sutehai: sutehai, tsumohai: dahai}, player_id, dahai) do
    sutehai = Map.update!(sutehai, player_id, fn tiles -> [%{hai: dahai, tsumogiri: true} | tiles] end)
    game = %__MODULE__{game | tsumohai: nil, sutehai: sutehai}

    {:ok, game}
  end

  def dahai(game = %__MODULE__{tehai: tehai, sutehai: sutehai, tsumohai: tsumohai}, player_id, dahai) do
    if dahai in Map.get(tehai, player_id) do
      sutehai = Map.update!(sutehai, player_id, fn tiles -> [%{hai: dahai, tsumogiri: false} | tiles] end)
      tehai = Map.update!(tehai, player_id, fn tiles -> [tsumohai | Enum.reject(tiles, &(&1 == dahai))] end)
      game = %__MODULE__{game | tsumohai: nil, tehai: tehai, sutehai: sutehai}

      {:ok, game}
    else
      {:error, :not_in_your_hand}
    end
  end
end
