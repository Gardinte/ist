defmodule Ist.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ist,
      version: "0.0.1",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: releases()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Ist.Application, []},
      extra_applications: [:logger, :runtime_tools, :mix]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, ">= 1.4.0"},
      {:phoenix_pubsub, ">= 1.1.0"},
      {:phoenix_html, ">= 2.14.0"},
      {:phoenix_ecto, ">= 4.1.0"},
      {:ecto_sql, ">= 3.4.0", override: true},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_reload, ">= 1.2.0", only: :dev},
      {:jason, ">= 1.2.0", override: true},
      {:gettext, ">= 0.17.0"},
      {:plug_cowboy, ">= 2.1.0"},
      {:argon2_elixir, ">= 2.3.0"},
      {:scrivener_ecto, ">= 2.3.0"},
      {:scrivener_html, ">= 1.8.0"},
      {:bamboo, ">= 1.4.0"},
      {:paper_trail, ">= 0.8.0"},
      {:timex, ">= 3.6.0"},
      {:guss, ">= 0.1.0"},
      {:psb, ">= 0.1.0", github: "gardinte/psb", branch: "master"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "run priv/repo/test_seeds.exs", "test"]
    ]
  end

  defp releases do
    [
      ist: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent]
      ]
    ]
  end
end
