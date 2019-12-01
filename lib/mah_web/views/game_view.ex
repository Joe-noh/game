defmodule MahWeb.GameView do
  use MahWeb, :view

  def render("show.json", %{game: game}) do
    %{data: render_one(game, __MODULE__, "game.json")}
  end

  def render("game.json", %{game: game}) do
    %{
      game: game
    }
  end
end
