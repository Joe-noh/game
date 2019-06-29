defmodule Mj.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      version: "0.0.1",
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  defp releases do
    [
      game: [
        applications: [
          mj: :permanent,
          mj_web: :permanent,
          runtime_tools: :permanent
        ],
        include_executables_for: [:unix]
      ]
    ]
  end

  defp deps do
    []
  end
end
