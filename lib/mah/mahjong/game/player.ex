defmodule Mah.Mahjong.Game.Player do
  alias Mah.Mahjong.Game

  @type dahai :: %{
          hai: Game.tile(),
          tsumogiri: bool(),
          reach: bool()
        }
  @type seki :: 0 | 1 | 2 | 3
  @type t :: %{
          point: integer(),
          tehai: Game.tiles(),
          tsumohai: Game.tile() | nil,
          furo: list(Game.Call.t()),
          sutehai: list(dahai()),
          seki: seki()
        }

  defstruct point: 0,
            tehai: [],
            tsumohai: nil,
            furo: [],
            sutehai: [],
            seki: 0

  @spec reach?(player :: t()) :: bool()
  def reach?(%__MODULE__{sutehai: sutehai}) do
    Enum.any?(sutehai, fn s -> Map.get(s, :reach) end)
  end

  @spec chakuseki(player :: t(), seki :: seki(), point :: non_neg_integer()) :: {:ok, t()} | {:error, atom()}
  def chakuseki(player, seki, point) when seki in 0..3 do
    {:ok, %__MODULE__{player | point: point, seki: seki}}
  end

  def chakuseki(_player, _seki) do
    {:error, :invalid}
  end

  @spec haipai(player :: t(), tiles :: Game.tiles()) :: {:ok, t()}
  def haipai(player, tiles) do
    {:ok, %__MODULE__{player | tehai: Enum.sort(tiles), tsumohai: nil, furo: [], sutehai: []}}
  end

  @spec tsumo(player :: t(), tile :: Game.tiles()) :: {:ok, t()}
  def tsumo(player = %__MODULE__{tsumohai: nil}, tile) do
    {:ok, %__MODULE__{player | tsumohai: tile}}
  end

  def tsumo(_player, _tile) do
    {:error, :invalid}
  end

  @spec dahai(player :: t(), hai :: Game.tile(), opts :: [reach: bool()]) :: {:ok, t()} | {:error, atom()}
  def dahai(player, hai, opts \\ [])

  def dahai(player = %__MODULE__{tehai: tehai}, hai, opts) do
    if hai in tehai do
      do_dahai(player, hai, opts)
    else
      {:error, :not_in_your_hand}
    end
  end

  defp do_dahai(player = %__MODULE__{tsumohai: hai, sutehai: sutehai}, hai, opts) do
    reach = Keyword.get(opts, :reach, false)
    sutehai = [%{hai: hai, tsumogiri: true, reach: reach} | sutehai]
    player = %__MODULE__{player | sutehai: sutehai}

    {:ok, player}
  end

  defp do_dahai(player = %__MODULE__{tehai: tehai, tsumohai: tsumohai, sutehai: sutehai}, hai, opts) do
    reach = Keyword.get(opts, :reach, false)
    sutehai = [%{hai: hai, tsumogiri: false, reach: reach} | sutehai]
    tehai = swap_tiles(tehai, tsumohai, hai)
    player = %__MODULE__{player | tehai: tehai, tsumohai: nil, sutehai: sutehai}

    {:ok, player}
  end

  @spec swap_tiles(tiles :: Game.tiles(), in_tile :: Game.tile(), out_tile :: Game.tile()) :: Game.tiles()
  defp swap_tiles(tiles, in_tile, out_tile) do
    [in_tile | tiles]
    |> Enum.sort()
    |> Enum.reject(fn t -> t == out_tile end)
  end
end
