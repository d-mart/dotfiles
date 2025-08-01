local mash = {"cmd", "alt", "ctrl"}
local mashshift = {"cmd", "alt", "shift"}

-- Things to incorporate:
--
-- https://github.com/thenerdlawyer/Hammerspoon/blob/master/init.lua

-- add luarocks to package path
package.path = "/usr/local/share/lua/5.3/?.lua;/usr/local/share/lua/5.3/?/init.lua;"..package.path
package.cpath = "/usr/local/lib/lua/5.3/?.so;"..package.cpath

require("hs.ipc")

package.path = './?.lua;' .. package.path
require("utils")
require("app_focus")
require("caffeine")
require("wifi-automation")

-- Load some 3rd party modules
-- https://github.com/scottwhudson/Lunette
-- Note to self: mine are better
-- if file_exists("Spoons/Lunette/Lunette.spoon/init.lua") then
--   hs.loadSpoon("Lunette")
--   spoon.Lunette:bindHotkeys()
-- end

-- if file_exists("Spoons/ControlEscape.spoon/init.lua") then
--   hs.loadSpoon("ControlEscape")
--   spoon.ControlEscape:start()
-- end


-- some shortcuts
bind       = hs.hotkey.bind
grid       = hs.grid
window     = hs.window
focusedWin = window.focusedWindow

-- setup
grid.MARGINX = 0
grid.MARGINY = 0
grid.GRIDHEIGHT = 3
grid.GRIDWIDTH  = 3

-- key bindings
--bind(mashshift, 'R', openconsole)
bind(mash, 'R', hs.reload)

bind(mash, ';', function() grid.snap(hs.window.focusedWindow()) end)
bind(mash, "'", function() hs.fnutils.map(hs.window.visibleWindows(), grid.snap) end)
bind(mash, '=', function() grid.adjustWidth( 1) end)
bind(mash, '-', function() grid.adjustWidth(-1) end)

bind(mashshift, 'H', function() window.focusedWindow():focusWindowWest()  end)
bind(mashshift, 'L', function() window.focusedWindow():focusWindowEast()  end)
bind(mashshift, 'K', function() window.focusedWindow():focusWindowNorth() end)
bind(mashshift, 'J', function() window.focusedWindow():focusWindowSouth() end)

bind(mash, 'M', grid.maximizeWindow)
bind(mash, 'N', grid.pushWindowNextScreen)
bind(mash, 'P', grid.pushWindowPrevScreen)

bind(mash, 'J', grid.pushWindowDown)
bind(mash, 'K', grid.pushWindowUp)
bind(mash, 'H', grid.pushWindowLeft)
bind(mash, 'L', grid.pushWindowRight)

bind(mash, 'Y', grid.resizeWindowThinner)
bind(mash, 'U', grid.resizeWindowShorter)
bind(mash, 'I', grid.resizeWindowTaller)
bind(mash, 'O', grid.resizeWindowWider)

-- debugging utility
function dump_table(t)
  print "--"
  for key,value in pairs(t) do
    print("  ", key, " = ", value)
  end
  print "--"
end

-- Use a secure password for encrypted drives
function paste_into_secure_dialog()
  paste_into_secure_applescript = [[
    # Set clipboard to disk unlock password, open unlock dialog, then run this script
    tell application "System Events" to tell process "SecurityAgent"
	  set value of text field 1 of window 1 to (the clipboard)
	  click button 1 of window 1
    end tell
  ]]
  print("Pasting into secure dialog...")
  hs.osascript.applescript(paste_into_secure_applescript)
end

-- eject all ejectable drives
function eject_all()
  eject_all_applescript = 'tell application "Finder" to eject (every disk whose ejectable is true)'
  print("Ejecting all drives...")
  hs.osascript.applescript(eject_all_applescript)
end

bind(mash, 'V', paste_into_secure_dialog)
bind(mash, 'X', eject_all)
bind(mash, 'escape', function() hs.osascript.applescript('tell application "ScreenSaverEngine" to activate') end)

z = hs.hotkey.modal.new(mash, 'Z')
function z:entered() hs.alert.show('?') end
function z:exited()  hs.alert.closeAll(); hs.alert.show('✓', 0.2) end
z:bind({}, 'escape', function() z:exit() end)
z:bind({}, 'f',      function() type_this('Device.find_by_serial_number('); z:exit() end)
z:bind({}, 'g',      function() type_this('find by serial number'); z:exit() end)
z:bind({}, 'h',      function() type_this('XXX'); z:exit() end)
z:bind({}, 'e',      function() focus_emacs(); z:exit() end)
z:bind({}, 'i',      function() focus_term();  z:exit() end)

--
-- map win7-like snap to each arrow key
--
-- ERRRG - maps all keys to the last entry in the array :-/
-- half_snaps = { "Left", "Right", "Down", "Up"}
-- for i = 1, #half_snaps do
--   direction = half_snaps[i]
--   print(i, "Mapping direction ", direction)
--   hs.hotkey.bind(mash, direction, function() half_window(direction) end)
-- end
hs.hotkey.bind(mash, "Left",  function()  half_window("Left")  end)
hs.hotkey.bind(mash, "Right", function()  half_window("Right") end)
hs.hotkey.bind(mash, "Up",    function()  half_window("Up")    end)
hs.hotkey.bind(mash, "Down",  function()  half_window("Down")  end)

-- ------------------------------------------
-- --------- Utility Functions --------------
-- ------------------------------------------

-- where_arg: "left" | "right" | "up" | "down"
function half_window(where_arg)
  local win = hs.window.focusedWindow()
  local f   = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  local where = string.lower(where_arg)

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h

  if where == "left" or where == "right" then
    f.w = f.w / 2
  end

  if where == "right" then
    f.x = f.x + f.w
  end

  if where == "up" or where == "down" then
    f.h = f.h / 2
  end

  if where == "down" then
    f.y = f.y + f.h
  end

  win:setFrame(f)
end

-- insert keyboard events - "type" passed string
function type_this(str)
  print("typing this: " .. str)
  hs.eventtap.keyStrokes(str)
end
