# Hammerspoon

macOS only. This directory is symlinked to `~/.hammerspoon`, and `install.sh` installs Hammerspoon with `brew install --cask hammerspoon` if it is missing.

## `init.lua`: input source follows USB devices

Switches the macOS input source based on which USB devices are attached:

| State                          | Input source   |
| ------------------------------ | -------------- |
| Any device in `DEVICES` attached | U.S.           |
| None attached                  | Wilson Dvorak  |

The check runs at config load and about one second after a plug or unplug event for a listed device. If the USB state can't be read, the input source is left unchanged.

### Configuration

Edit the constants at the top of `init.lua`:

```lua
local DEVICES = {
  { name = "Keychron V6 8K", vendorID = 0x3434, productID = 0x0F60, serial = "6885A90000C0A6210687BD1300000000" },
}

local ATTACHED_SOURCE = "com.apple.keylayout.US"
local DETACHED_SOURCE = "org.sil.ukelele.keyboardlayout.unsavedukeleledocument.wilsondvorak"
```

- `vendorID` and `productID` filter the events from `hs.usb.watcher`, which doesn't report serial numbers.
- `serial` is matched against `ioreg` output, so two units of the same model are told apart.
- `name` is for humans only.

### Finding a device's IDs

`ioreg` prints the values in decimal; convert them to hex for `vendorID` and `productID`:

```sh
ioreg -p IOUSB -l -w 0 | grep -E '"(USB Product Name|idVendor|idProduct|kUSBSerialNumberString)"'
```

### Finding input source IDs

Source IDs can be listed from the Hammerspoon console:

```lua
hs.inspect(hs.keycodes.layouts(true))
```

Custom layouts such as Wilson Dvorak (`~/Library/Keyboard Layouts/`) are not synced by this repo and must be installed separately.

### Applying changes

Reload the config from the Hammerspoon menu bar icon, or run `hs.reload()` in the console. Problems are logged to the Hammerspoon console with a `usb-layout:` prefix.
