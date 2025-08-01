local success, wifi_config = pcall(require, 'private_ssids')

if success then
 inspect_value(wifi_config)
else
  wifiConfig = {}
  hs.alert.show("private_ssids.lua not found.\nWiFi automations will be disabled.")
end

local last_ssid = hs.wifi.currentNetwork()

-- Create a wifi watcher and start it, but only upon success of loading config
local function wifi_changed(watcher)
  ssid = hs.wifi.currentNetwork()

  if ssid ~= last_ssid then
    if ssid then
      if list_contains(wifi_config.office_wifi_list, ssid) then
        print("Activating Office Profile for " .. ssid)
        hs.application.launchOrFocus("Slack")
        hs.audiodevice.defaultOutputDevice():setVolume(0)
      elseif list_contains(wifi_config.home_wifi_list, ssid) then
        print("Activating Home Profile for " .. ssid)
        -- TODO
      elseif list_contains(wifi_config.tether_wifi_list, ssid) then
        print("Activating Tether Profile for " .. ssid)
        -- TODO
      else
        print("Unknown wifi: " .. ssid)
      end
    end

    last_ssid = ssid
  end
end

if success then
  wifi_watcher = hs.wifi.watcher.new(wifi_changed)
  wifi_watcher:start()
  print("Hammerspoon wifi automation started.")
end
