defmodule Mj.Mahjong do
  @moduledoc """
  """

  @all_tile_ids 0..135

  def haipai(players, _rule) do
    tiles = @all_tile_ids |> Enum.shuffle()

    {yamahai, tiles} = Enum.split(tiles, 70)
    {rinshanhai, tiles} = Enum.split(tiles, 4)
    {wanpai, tiles} = Enum.split(tiles, 10)

    players = Enum.shuffle(players) # 席順 (東南西北)

    hands =
      Enum.chunk_every(tiles, 13)
      |> Enum.zip(players)
      |> Enum.reduce(%{}, fn {tehai, player}, acc ->
        Map.put(acc, player, %{tehai: tehai, furo: [], sutehai: []})
      end)

    %{players: players, hands: hands, yamahai: yamahai, rinshanhai: rinshanhai, wanpai: wanpai}
  end
end
