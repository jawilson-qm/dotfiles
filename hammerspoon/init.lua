-- Switch the input source based on whether any of the listed USB devices is attached:
-- any attached -> ATTACHED_SOURCE, none attached -> DETACHED_SOURCE.
local DEVICES = {
  { name = "Keychron V6 8K", vendorID = 0x3434, productID = 0x0F60, serial = "6885A90000C0A6210687BD1300000000" },
}

local ATTACHED_SOURCE = "com.apple.keylayout.US"
local DETACHED_SOURCE = "org.sil.ukelele.keyboardlayout.unsavedukeleledocument.wilsondvorak"

local function anyDeviceAttached()
  -- hs.usb doesn't expose serial numbers, so ask the IORegistry.
  local output, ok = hs.execute("/usr/sbin/ioreg -p IOUSB -l -w 0")
  if not ok then
    return nil
  end
  for _, device in ipairs(DEVICES) do
    if output:find(device.serial, 1, true) then
      return true
    end
  end
  return false
end

local function isListedDevice(event)
  for _, device in ipairs(DEVICES) do
    if event.vendorID == device.vendorID and event.productID == device.productID then
      return true
    end
  end
  return false
end

local function applyInputSource()
  local attached = anyDeviceAttached()
  if attached == nil then
    hs.printf("usb-layout: could not read USB state; leaving input source unchanged")
    return
  end

  local source = attached and ATTACHED_SOURCE or DETACHED_SOURCE
  if hs.keycodes.currentSourceID() ~= source and not hs.keycodes.currentSourceID(source) then
    hs.printf("usb-layout: could not switch input source to %s", source)
  end
end

usbWatcher = hs.usb.watcher.new(function(event)
  if isListedDevice(event) then
    -- Give the IORegistry a moment to settle after the event.
    hs.timer.doAfter(1, applyInputSource)
  end
end)
usbWatcher:start()

applyInputSource()
