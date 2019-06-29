defmodule Mj.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Mj.Repo,
      {DynamicSupervisor, name: Mj.GameSupervisor, strategy: :one_for_one},
      {Registry, keys: :unique, name: Mj.GameRegistry}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Mj.Supervisor)
  end
end
