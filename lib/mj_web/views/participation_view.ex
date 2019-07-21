defmodule MjWeb.ParticipationView do
  use MjWeb, :view

  def render("show.json", %{participation: participation}) do
    %{data: render_one(participation, __MODULE__, "participation.json")}
  end

  def render("participation.json", %{participation: participation}) do
    %{
      game_id: participation.game_id
    }
  end
end
