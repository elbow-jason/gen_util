defmodule GenUtil.Mixfile do
  use Mix.Project

  def project do
    [
      app: :gen_util,
      version: "0.2.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      name: "GenUtil",
      source_url: "https://github.com/elbow-jason/gen_util",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev}
    ]
  end

  defp description do
    """
    A collection of Utility functions.
    """
  end

  defp package do
    # These are the default files included in the package
    [
      name: :gen_util,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jason Goldberger"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/elbow-jason/gen_util"}
    ]
  end
end
