
function focus_term()
  hs.application.launchOrFocus("iTerm")
end

function focus_emacs()
  emacs = hs.application.find("emacs")
  emacs:activate()
end

function hide_vlc()
  vlc = hs.application.find("vlc")
  vlc:activate()
  hs.eventtap.keyStroke({"cmd"}, ".") -- stop
  hs.application.find("vlc"):hide()
  print("back to work")
end
