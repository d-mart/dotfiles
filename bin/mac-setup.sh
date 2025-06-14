#!/usr/bin/env bash

# TODO: macs seem to default to a 20 minute sudo. Consider
#       streamlining this or at least doing manually first
# visudo, then add the line:
# Defaults timestamp_timeout=60

# set -e

unset KEEP_SUDO_WARM_PID

## helpers
function echo_ok    { echo -e '\033[1;32m'"$1"'\033[0m'; }
function echo_warn  { echo -e '\033[1;33m'"$1"'\033[0m'; }
function echo_error { echo -e '\033[1;31mERROR: '"$1"'\033[0m'; }

function mkdir_with_ln() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
  fi

  if [ ! -e "$2" ]; then
    ln -s "$1" "$2"
  fi
}

function cleanup() {
  echo "Cleaning up..."
  if [ -n "$KEEP_SUDO_WARM_PID" ]; then
    kill $KEEP_SUDO_WARM_PID 2>/dev/null
  fi
  exit 1
}

# Function to keep sudo warm in the background
# worst case, will run 2 hours, but should be stopped by this script
function keep_sudo_warm() {
  end_time=$((SECONDS + 7200))  # 2 hours in seconds
  while [ $SECONDS -lt $end_time ]; do
    echo "running sudo...."
    sudo -v  # Refresh the sudo timestamp
    sleep 15 # Wait for 15 seconds before refreshing again
  done
}

function install_command_line_tools() {
  xcode-select --install
  echo "🚨Install for macos command-line tools has been requested. Check for a popup under other windows."
  echo "🚨 Run this script again once it finishes."
}

declare -a brewlist=(
  "ag"
  "asdf"
  "autossh"
  "bash"
  "bat"
  "bat-extras"
  "broot"
  "btop"
  "calc"
  "coreutils"
  "datamash"
  "dblab"
  "diff-so-fancy"
  "difftastic"
  "direnv"
  "dockerfmt"
  "emacs-plus"
  "eza"
  "fd"
  "fpp"
  "fswatch"
  "fzf"
  "fzy"
  "gawk"
  "git"
  "gitui"
  "git-delta"
  "gnu-sed"
  "gpg2"
  "httpie"
  "hub"
  "icdiff"
  "jq"
  "noahgorstein/tap/jqp"
  "jump"
  "k9s"
  "krew"
  "lf"
  "lsd"
  "mdv"
  "nmap"
  "nnn"
  "openssh"
  "pgcli"
  "pipx"
  "podman"
  "podman-compose"
  "podman-tui"
  "pwgen"
  "ranger"
  "ripgrep"
  "sc-im"
  "starship"
  "stern"
  "superfile"
  "tealdeer"
  "teleport"
  "telnet"
  "terminal-notifier"
  "tmux"
  "tmuxinator"
  "tree"
  "vim"
  "saulpw/vd/visidata"
  "watch"
  "z"
  "zlib"
  "zsh"
  "yqrashawn/goku/goku"
)

declare -a brewcasklist=(
  "alfred"
  "betterzip"
  "brave-browser"
  "cursor"
  "firefox"
  "firefox@developer-edition"
  "font-anonymous-pro"
  "font-cascadia-mono"
  "font-cascadia-code"
  "font-dejavu-sans-mono-for-powerline"
  "font-droidsansmono-nerd-font"
  "font-droid-sans-mono-for-powerline"
  "font-fira-code"
  "font-fira-mono"
  "font-fira-mono-for-powerline"
  "font-hack"
  "font-hack-nerd-font"
  "font-inconsolata"
  "font-inconsolata-for-powerline"
  "font-iosevka"
  "font-iosevka-nerd-font"
  "font-iosevka-nerd-font-mono"
  "font-iosevka-slab"
  "font-liberation-sans"
  "font-liberationmono-nerd-font"
  "font-liberation-mono-for-powerline"
  "font-jetbrains-mono"
  "font-monaspace"
  "font-meslo-lg"
  "font-input"
  "font-meslo-lg"
  "font-nixie-one"
  "font-office-code-pro"
  "font-pt-mono"
  "font-raleway"
  "font-roboto"
  "font-source-code-pro"
  "font-source-code-pro-for-powerline"
  "font-victor-mono"
  "gimp"
  "hammerspoon"
  "insomnia"
  "iterm2"
  "keepingyouawake"
  "librewolf"
  "lm-studio"
  "mark-text"
  "neohtop"
  "ngrok"
  "notunes"
  "podman-desktop"
  "quicklook-csv"
  "quicklook-json"
  "setapp"
  "suspicious-package"
  "syncthing"
  "utm"
  "vlc"
  "webpquicklook"
)

##
## Main entry point
##

# Trap SIGINT (Ctrl+C) and SIGTERM (kill)
trap cleanup SIGINT SIGTERM

# Prompt for sudo access
# XXXXXX echo "Please authorize sudo to enable unattended install..."
# XXXXXX sudo -v

# keep sudo access warm in the backgrouns
# XXXXXX keep_sudo_warm &
# XXXXXX KEEP_SUDO_WARM_PID=$!

## make some directories
mkdir_with_ln "$HOME/util" "$HOME/u"
mkdir_with_ln "$HOME/personal" "$HOME/p"
mkdir_with_ln "$HOME/workspace" "$HOME/w"
mkdir -p "$HOME/tmp"

## command line tools
xcode-select -p 1>/dev/null || install_command_line_tools

## System Prefs
# disable dashboard
defaults write com.apple.dashboard mcx-disabled -bool true
# not sure
defaults write com.apple.dock workspaces-auto-swoosh -bool false
# show cmd-tab ui on all monitors
defaults write com.apple.dock appswitcher-all-displays -bool true
# smallish dock
defaults write com.apple.dock tilesize -int 40
# a lil bit o zoom
defaults write com.apple.dock magnification -int 1
# no recent apps in dock
defaults write com.apple.dock show-recents -bool false
# dock on the right side of screen
defaults write com.apple.dock orientation -string "right"
# autohide dock
defaults write com.apple.dock autohide -bool true
# allow tap to perform a click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# show hidden files
defaults write com.apple.Finder AppleShowAllFiles -bool true
# don't ask "Are you sure you want to launch this?"
defaults write com.apple.LaunchServices LSQuarantine -bool false
# scroll the Right way
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
# more trackpad settings
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# fastest key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
# shortest key repeat delay
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# dark mode UI
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

mkdir -p ~/screenshots
defaults write com.apple.screencapture location ~/screenshots/

## Install homebrew
hash brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew tap buo/cask-upgrade # utility to update casks easily/automatically; 'brew cu [CASK]'

# Install each of the homebrew packages in the list
for package in "${brewlist[@]}"; do
  brew install "$package"
done

# Install each of the homebrew casks in the list
for cask in "${brewcasklist[@]}"; do
  brew install --cask "$cask"
done

# not in brew cask list because of command-line options
# icon option doesn't work brew tap d12frosted/emacs-plus --with-emacs-icons-project-EmacsIcon4
# so grab icon from here https://github.com/emacsfodder/emacs-icons-project/
#ln -s /usr/local/opt/emacs-plus/Emacs.app /Applications/Emacs.app
brew link --overwrite emacs-plus  # maybe not needed if regular emacs isn't present

## vim (just in case)
if [ ! -d ~/.vim_runtime ]; then
 git clone https://github.com/amix/vimrc.git ~/.vim_runtime
 sh ~/.vim_runtime/install_awesome_vimrc.sh
fi

## versions of stuff
# check for updates / others - https://github.com/asdf-vm/asdf-plugins/tree/master/plugins
asdf plugin add lua
asdf plugin add golang
asdf plugin add nodejs
asdf plugin add python
asdf plugin add ruby
asdf plugin add rust

# add gpg keys for node packages
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
asdf install nodejs latest
asdf set -u nodejs latest

# install a MRI / C-based ruby
asdf install ruby latest
asdf set -u ruby latest

# install a newish c-python
asdf install python latest
asdf set -u python latest

## Restart some things
killall Dock
killall SystemUIServer

## Add some more readline shortuvst
mkdir -p ~/Library/KeyBindings
curl -o \
     ~/Library/KeyBindings/DefaultKeyBinding.dict \
     https://gist.githubusercontent.com/cheapRoc/9670905/raw/1c1cd2e84daf07c9a4c8de0ff86d1baf75d858c6/EmacsKeyBinding.dict

## require password ... keep these last
if [ -x /opt/homebrew/bin/zsh ]; then
  sudo dscl . -create /Users/$USER UserShell /opt/homebrew/bin/zsh
fi

brew install --cask karabiner-elements

# do any cleanup
cleanup

echo "✅ Finished"
