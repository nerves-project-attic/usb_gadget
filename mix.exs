defmodule UsbGadget.MixProject do
  use Mix.Project

  def project do
    [
      app: :usb_gadget,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.18.0", only: :dev}
    ]
  end

  defp description do
    """
    Configure USB Gadget devices in Linux
    """
  end

  defp docs do
    [extras: ["README.md"], main: "readme"]
  end

  defp package do
    [
      maintainers: ["Greg Mefford", "Tim Mecklem", "Connor Rigby"],
      files: ["lib", "LICENSE", "mix.exs", "README.md"],
      licenses: ["Apache 2.0"],
      links: %{"Github" => "https://github.com/nerves-project/usb_gadget"}
    ]
  end
end
