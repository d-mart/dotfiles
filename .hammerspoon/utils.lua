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
