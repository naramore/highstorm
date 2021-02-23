defmodule Highstorm.MixProject do
  use Mix.Project

  @in_production Mix.env() == :prod
  @version "0.0.1"
  @author "naramore"
  @source_url "https://github.com/naramore/highstorm"
  @description """
  Datalog
  """

  def project do
    [
      app: :highstorm,
      version: @version,
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:boundary] ++ Mix.compilers(),
      build_embedded: @in_production,
      start_permanent: @in_production,
      aliases: aliases(),
      deps: deps(),
      description: @description,
      package: package(),
      name: "Highstorm",
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      boundary: [externals_mode: :relaxed],
      preferred_cli_env: [
        format: :test,
        credo: :test,
        dialyzer: :test,
        check: :test,
        coveralls: :test
      ],
      boundary: [
        default: [
          check: [
            apps: [:stream_data, {:mix, :runtime}]
          ]
        ]
      ],
      dialyzer: [
        flags: [
          :underspecs,
          :error_handling,
          :unmatched_returns,
          :unknown,
          :race_conditions
        ],
        plt_add_deps: :apps_direct,
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true,
        plt_core_path: "priv/plts"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      contributors: [@author],
      maintainers: [@author],
      source_ref: "v#{@version}",
      links: %{"GitHub" => @source_url},
      files: ~w(lib .formatter.exs mix.exs README.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(env) when env in [:dev, :test], do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:stream_data, "~> 0.5"},
      # {:benchee, "~> 1.0", only: [:dev, :test]},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.13", only: [:dev, :test]},
      # {:inch_ex, github: "rrrene/inch_ex", only: [:dev, :test]},
      # {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:boundary, "~> 0.7", runtime: false}
    ]
  end

  defp aliases do
    [
      home: &home/1,
      otp_vsn: &otp_version/1,
      check: [
        "compile --warnings-as-errors",
        "credo",
        "dialyzer",
        "test",
        "format"
      ]
    ]
  end

  defp home(_) do
    Mix.shell().info("#{Mix.Utils.mix_home()}")
  end

  defp otp_version(_) do
    Mix.shell().info("#{otp_vsn()}")
  end

  defp otp_vsn(major \\ otp_release()) do
    Path.join([:code.root_dir(), "releases", major, "OTP_VERSION"])
    |> File.read!()
    |> String.split(["\r\n", "\r", "\n"], trim: true)
    |> case do
      [full | _] -> full
      _ -> major
    end
  catch
    _ -> major
  end

  defp otp_release() do
    :erlang.system_info(:otp_release) |> List.to_string()
  end
end
