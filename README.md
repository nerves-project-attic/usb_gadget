# USBGadget

Configure USB Gadget functions on your Nerves-based embedded device using
ConfigFS.

## 🚨 This project is work-in-progress 🚨

The intention is that it will become a dependency of [`nerves_init_gadget`] to
allow for automatic configuration of USB Gadget devices as well as an API for
developers to configure their own custom USB Gadget configurations.

[nerves_init_gadget]: https://github.com/nerves-project/nerves_init_gadget

## Installation

To use it directly in your project (i.e. without `nerves_init_gadget`, add
`usb_gadget` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:usb_gadget, "~> 0.1.0"}
  ]
end
```

Documentation can be found at
[https://hexdocs.pm/usb_gadget](https://hexdocs.pm/usb_gadget).

