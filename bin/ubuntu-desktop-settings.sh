
## list settings
# dconf dump / | grep -i "suspend|sleep"
# gsettings list-recursively | grep -i "suspend|sleep"

#
gsettings set org.gnome.desktop.session idle-delay 14400 # seconds 3600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 39600
gsettings set org.gnome.mutter workspaces-only-on-primary false # workspace switcher on all monitors
