# USBGadget

Configure USB Gadget functions on your Nerves-based embedded device using
ConfigFS.

While you can use this library directly to configure custom USB gadget devices,
its primary function at the moment is to be used by [`nerves_init_gadget`] to
allow for automatic configuration of the default USB Gadget devices on targets
like `rpi0` and `bbb`.

[nerves_init_gadget]: https://github.com/nerves-project/nerves_init_gadget

## Installation

To use it directly in your project (i.e. without `nerves_init_gadget`), add
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
