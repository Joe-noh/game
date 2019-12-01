defmodule Mah.Mahjong.Game.Rule do
  @derive Jason.Encoder
  defstruct num_players: 4,
            initial_point: 25_000
end
