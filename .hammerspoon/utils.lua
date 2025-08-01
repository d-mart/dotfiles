-- true if a file is readable
function file_exists(filename)
  local f = io.open(filename, "r")
  if f~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function inspect_value(value)
  print("Type: " .. type(value))
  if type(value) == "table" then
    for k, v in pairs(value) do
      print("  [" .. tostring(k) .. "] = " .. tostring(v))
    end
  else
    print("Value: " .. tostring(value))
  end
end

function list_contains(list, value)
  if not list then
    return false
  end

  for _, item in ipairs(list) do
    if item == value then
      return true
    end
  end

  return false
end

-- for macos wifi interactions, force request of location access
-- (call this from the console if/as needed)
function force_location_request()
  -- Temporarily add this code to trigger the Location Services prompt
  hs.location.start()
  hs.alert.show("Attempting to get location to trigger permission prompt...")

  -- This will stop location tracking after 15 seconds to save battery
  hs.timer.doAfter(15, function()
                     hs.location.stop()
                     hs.alert.show("Location tracking stopped.")
  end)
end
