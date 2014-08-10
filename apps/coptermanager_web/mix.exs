defmodule CoptermanagerWeb.Mixfile do
  use Mix.Project

  def project do
    [ app: :coptermanager_web,
      version: "0.0.1",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 0.15.0",
      elixirc_paths: ["lib", "web"],
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [
      mod: { CoptermanagerWeb, [] },
      applications: [:phoenix]
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [
      {:phoenix, github: "phoenixframework/phoenix"},
      {:cowboy, "~> 1.0.0"},
      {:timex, "~> 0.11.0"},
      {:phoenix_dtl, github: "andihit/phoenix_dtl"}
    ]
  end
end
