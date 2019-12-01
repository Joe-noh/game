defmodule Mah.Mahjong.Game.Call do
  alias Mah.Mahjong.Game

  @type type :: :chi | :pon | :ankan | :minkan | :kakan
  @type from :: :kamicha | :toimen | :shimocha | nil
  @type t :: %{
          type: type(),
          from: from(),
          tiles: Game.tiles()
        }

  @derive Jason.Encoder
  defstruct type: :chi,
            from: :kamicha,
            tiles: []

  @spec new(type :: type(), from :: from(), tiles :: Game.tiles()) :: {:ok, t()} | {:error, atom()}
  def new(type, from, tiles)

  def new(:pon, from, tiles) do
    if kotsu?(tiles) do
      {:ok, %__MODULE__{type: :pon, from: from, tiles: tiles}}
    else
      {:error, :not_kotsu}
    end
  end

  def new(:chi, :kamicha, tiles) do
    if shuntsu?(tiles) do
      {:ok, %__MODULE__{type: :chi, from: :kamicha, tiles: tiles}}
    else
      {:error, :not_shuntu}
    end
  end

  def new(:chi, _not_kamicha, _tiles) do
    {:error, :not_from_kamicha}
  end

  def new(:ankan, nil, tiles) when length(tiles) == 4 do
    if kantsu?(tiles) do
      {:ok, %__MODULE__{type: :ankan, from: nil, tiles: tiles}}
    else
      {:error, :not_kantsu}
    end
  end

  def new(:ankan, _from, _tiles) do
    {:error, :invalid}
  end

  def new(:minkan, from, tiles) when length(tiles) == 4 do
    if kantsu?(tiles) do
      {:ok, %__MODULE__{type: :minkan, from: from, tiles: tiles}}
    else
      {:error, :not_kantsu}
    end
  end

  def new(:minkan, _from, _tiles) do
    {:error, :invalid}
  end

  def new(:kakan, _from, _tiles) do
    {:error, :invalid}
  end

  @spec kakan(call :: t(), tile :: Game.tile()) :: {:ok, t()} | {:error, atom()}
  def kakan(call, tile)

  def kakan(call = %__MODULE__{type: :pon, tiles: tiles}, tile) do
    if kantsu?([tile | tiles]) do
      {:ok, %__MODULE__{call | type: :kakan, tiles: [tile | tiles]}}
    else
      {:error, :not_kantsu}
    end
  end

  def kakan(%__MODULE__{type: _not_pon}, _tile) do
    {:error, :invalid}
  end

  defp kotsu?(tiles) do
    length(tiles) == 3 and same?(tiles)
  end

  defp kantsu?(tiles) do
    length(tiles) == 4 and same?(tiles)
  end

  defp same?(tiles) do
    tiles
    |> Enum.map(&div(&1, 4))
    |> Enum.dedup()
    |> case do
      [_] -> true
      _ -> false
    end
  end

  defp shuntsu?(tiles) do
    tiles
    |> Enum.map(&div(&1, 4))
    |> Enum.sort()
    |> sequential?()
  end

  # includes 9m and 1p
  defp sequential?([7, 8, 9]), do: false
  defp sequential?([8, 9, 10]), do: false

  # includes 9p and 1s
  defp sequential?([16, 17, 18]), do: false
  defp sequential?([17, 18, 19]), do: false

  # includes winds or dragons
  defp sequential?([x | _]) when x > 24, do: false

  defp sequential?([a, b, c]) when a + 1 == b and a + 2 == c, do: true

  defp sequential?(_), do: false
end
