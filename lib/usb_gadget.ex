defmodule USBGadget do
  @moduledoc """
  Some good documentation about ConfigFS can be found here:
  * <https://elinux.org/images/e/ef/USB_Gadget_Configfs_API_0.pdf>
  * <https://www.kernel.org/doc/Documentation/usb/gadget_configfs.txt>
  * <https://www.kernel.org/doc/Documentation/filesystems/configfs/configfs.txt>
  * <https://docs.microsoft.com/en-us/windows-hardware/drivers/usbcon/usb-interface-association-descriptor>
  * <https://www.usb.org/sites/default/files/iadclasscode_r10.pdf>
  """

  require Logger

  @gadget_root Application.get_env(:usb_gadget, :root, "/sys/kernel/config/usb_gadget")

  @doc """
  Define a USB Gadget device

  ## Examples

      iex> USBGadget.create_device("g", %{
        "bcdUSB" => "0x0200",
        "bDeviceClass" => "0xEF",
        "bDeviceSubClass" => "0x02",
        "bDeviceProtocol" => "0x01",
        "idVendor" => "0xDEAD",
        "idProduct" => "0xBEEF",
        "bcdDevice" => "0x0100",
        "os_desc" => %{
          "use" => "1",
          "b_vendor_code" => "0xcd",
          "qw_sign" => "MSFT100"
        },
        "strings" => %{
          "0x409" => %{
            "manufacturer" => "ACME"
            "product" => "USB-O-Tron 9001"
            "serialnumber" => "1"
          }
        }
      })
      :ok
  """
  def create_device(device_name, attrs \\ %{}) do
    set_attribute(@gadget_root, {device_name, attrs})
  end

  @doc """
  Define a function the device will support

  ## Examples

      iex> USBGadget.create_function("g", "rndis.usb0", %{
        "dev_addr" => "de:ad:be:ef:00:00",
        "host_addr" => "de:ad:be:ef:00:02",
        "os_desc" => %{
          "interface.rndis" => %{
            "compatible_id" => "RNDIS",
            "sub_compatible_id" => "5162001"
          }
        }
      })
      :ok
  """
  def create_function(device_name, function_name, attrs \\ %{}) do
    [@gadget_root, device_name, "functions"]
    |> Path.join()
    |> set_attribute({function_name, attrs})
  end

  @doc """
  Define a config for the device

  ## Examples

      iex> USBGadget.create_config("g", "c.1", %{
        "bmAttributes" => "0xC0",
        "MaxPower" => "1",
        "strings" => %{
          "0x409" => %{
            "configuration" => "Ethernet and Serial"
          }
        }
      })
      :ok
  """
  def create_config(device_name, config_name, attrs \\ %{}) do
    [@gadget_root, device_name, "configs"]
    |> Path.join()
    |> set_attribute({config_name, attrs})
  end

  @doc """
  Define the functions available for a given configuration of a device

  ## Examples

      iex> USBGadget.link_functions("g", "c.1", ["rndis.usb0", "ecm.usb1", "acm.GS0"])
      :ok
  """
  def link_functions(device_name, config_name, function_names) do
    function_root = Path.join([@gadget_root, device_name, "functions"])
    config_path = Path.join([@gadget_root, device_name, "configs", config_name])

    coalesce_error(function_names, fn function_name ->
      Logger.debug("Linking function #{function_name} > #{config_path}")
      File.ln_s(Path.join(function_root, function_name), Path.join(config_path, function_name))
    end)
  end

  @doc """
  Define the operating system descriptor to a configuration

  ## Examples

      iex> USBGadget.link_os_desc("g", "c.1")
      :ok
  """
  def link_os_desc(device_name, config_name) do
    Logger.debug("Linking os_desc #{device_name} > #{config_name}")
    config_path = Path.join([@gadget_root, device_name, "configs", config_name])
    os_desc_path = Path.join([@gadget_root, device_name, "os_desc", config_name])
    File.ln_s(config_path, os_desc_path)
  end

  @doc """
  Enable the gadget device, making the configured functions available to the operating system

  ## Examples

      iex> USBGadget.enable_device("g")
      :ok
  """
  def enable_device(device_name) do
    Logger.debug("Enabling device #{device_name}")

    with {:ok, [udc_name | _]} <- File.ls("/sys/class/udc"),
         do: File.write(udc_path(device_name), udc_name)
  end

  @doc """
  Disable the gadget device, making the configured functions no longer available to the operating system

  ## Examples

      iex> USBGadget.disable_device("g")
      :ok
  """
  def disable_device(device_name) do
    Logger.debug("Disabling device #{device_name}")

    device_name
    |> udc_path()
    |> File.write("\n")
  end

  # Private Helpers

  defp coalesce_error(enum, func) do
    Enum.reduce_while(enum, :ok, fn value, acc ->
      case func.(value) do
        :ok -> {:cont, acc}
        error -> {:halt, error}
      end
    end)
  end

  defp set_attribute(path, {name, %{} = values}) do
    attr_path = Path.join(path, name)

    with :ok <- File.mkdir_p(attr_path),
         do: coalesce_error(values, &set_attribute(attr_path, &1))
  end

  defp set_attribute(path, {name, value}) do
    Logger.debug("Setting attribute #{path}/#{name} => #{to_string(value)}")

    path
    |> Path.join(name)
    |> File.write(to_string(value))
  end

  defp udc_path(device_name), do: Path.join([@gadget_root, device_name, "UDC"])
end
