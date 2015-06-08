defmodule Weebo.Mixfile do
  use Mix.Project

  def project do
    [app: :weebo,
     version: "1.0.0",
     elixir: "~> 1.0",
     name: "Weebo",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/stevenschobert/weebo",
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.7", only: :docs},
     {:iso8601, github: "seansawyer/erlang_iso8601", tag: "1.1.1", compile: "#{Mix.Rebar.local_rebar_path} compile"}]
  end
end
