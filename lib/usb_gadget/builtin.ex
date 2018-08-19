defmodule USBGadget.Builtin do
  @moduledoc """
  These convenience functions allow you to quickly set up some pre-configured
  USB Gadget devices for common use-cases. The devices are configured but not
  enabled automatically, allowing them to be customized as needed.
  """

  import USBGadget

  @doc """
  Creates a USB Gadget device with RNDIS Ethernet, ECM Ethernet, and ACM
  serial interfaces.

  ## Examples
      iex> USBGadget.Builtin.create_rndis_ecm_acm("g")
      :ok
      iex> USBGadget.enable_device("g")
      :ok
  """
  def create_rndis_ecm_acm(name) do
    # * bcdUSB 0x200 means USB 2.0
    # * bDevice{Class,SubClass,Protocol} = {0xEF, 0x02, 0x01} means
    #   Interface Association Descriptor class
    # * idVendor and idProduct are reserved using http://pid.codes
    # * bcdDevice is the "firmware version" in binary-coded decimal
    #   so 0x0123 means 1.2.3
    # * These os_desc options tell Windows to use configuration 1
    # * strings/0x409 means EN-US.
    device_settings = %{
      "bcdUSB" => "0x0200",
      "bDeviceClass" => "0xEF",
      "bDeviceSubClass" => "0x02",
      "bDeviceProtocol" => "0x01",
      "idVendor" => "0x1209",
      "idProduct" => "0x0070",
      "bcdDevice" => "0x0100",
      "os_desc" => %{
        "use" => "1",
        "b_vendor_code" => "0xcd",
        "qw_sign" => "MSFT100"
      },
      "strings" => %{
        "0x409" => %{
          "manufacturer" => "Nerves Project",
          "product" => "Ethernet + Serial Gadget",
          "serialnumber" => ""
        }
      }
    }

    # This sub_compatible_id tells Windows to use the RNDIS driver version that
    # actually works instead of a newer one that doesn't. It's not well-
    # documented, but it's commonly used for Linux-based USB Gadgets.
    rndis_settings = %{
      "os_desc" => %{
        "interface.rndis" => %{
          "compatible_id" => "RNDIS",
          "sub_compatible_id" => "5162001"
        }
      }
    }

    # * bmAttributes is a bitmap field:
    #   * bit 7 (MSB) is reserved in USB 2.0 and set to 1
    #   * bit 6 set means the device is self-powered
    #   * bit 5 set means the device can wake the host from suspend
    #   * bits 4..0 are reserved and set to 0
    # * MaxPower is the max current the device will draw (in mA)
    config1_settings = %{
      "bmAttributes" => "0xC0",
      "MaxPower" => "500",
      "strings" => %{
        "0x409" => %{
          "configuration" => "RNDIS and ECM Ethernet with ACM Serial"
        }
      }
    }

    function_list = ["rndis.usb0", "ecm.usb1", "acm.GS0"]

    with {:create_device, :ok} <- {:create_device, create_device(name, device_settings)},
         {:create_rndis, :ok} <- {:create_rndis, create_function(name, "rndis.usb0", rndis_settings)},
         {:create_ecm, :ok} <- {:create_ecm, create_function(name, "ecm.usb1", %{})},
         {:create_acm, :ok} <- {:create_acm, create_function(name, "acm.GS0")},
         {:create_config, :ok} <- {:create_config, create_config(name, "c.1", config1_settings)},
         {:link_functions, :ok} <- {:link_functions, link_functions(name, "c.1", function_list)},
         {:link_os_desc, :ok} <- {:link_os_desc, link_os_desc(name, "c.1")} do
      :ok
    else
      {failed_step, {:error, reason}} -> {:error, {failed_step, reason}}
    end
  end
end
