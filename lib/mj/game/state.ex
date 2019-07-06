defmodule Mj.Game.State do
  defstruct id: nil,
            players: []

  def new(id) do
    %__MODULE__{id: id}
  end
end
