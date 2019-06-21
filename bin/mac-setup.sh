#!/usr/bin/env bash

set -e

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

declare -a brewlist=(
  "ag"
  "asdf"
  "autossh"
  "bash"
  "bat"
  "coreutils"
  "datamash"
  "diff-so-fancy"
  "direnv"
  "exa"
  "fasd"
  "fd"
  "fpp"
  "fzf"
  "gawk"
  "git"
  "gnu-sed"
  "gnu-awk"
  "gpg2"
  "httpie"
  "hub"
  "jq"
  "openssh"
  "pwgen"
  "ranger"
  "telnet"
  "tmux"
  "tree"
  "vim"
  "zlib"
  "zsh"
)

declare -a brewcasklist=(
  "alfred"
  "appcleaner"
  "betterzip"
  "caffeine"
  "docker"
  "dozer"
  "dropbox"
  "emacs"
  "firefox"
  "flux"
  "font-anonymous-pro"
  "font-dejavu-sans-mono-for-powerline"
  "font-droidsansmono-nerd-font"
  "font-droid-sans-mono-for-powerline"
  "font-inconsolata"
  "font-inconsolata-for-powerline"
  "font-liberation-sans"
  "font-liberationmono-nerd-font"
  "font-liberation-mono-for-powerline"
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
  "font-source-sans-pro"
  "google-chrome"
  "hammerspoon"
  "insomnia"
  "iterm2"
  "ngrok"
  "private-internet-access"
  "qlcolorcode"
  "qlmarkdown"
  "qlprettypatch"
  "qlstephen"
  "quicklook-csv"
  "quicklook-json"
  "slack"
  "superduper"
  "suspicious-package"
  "tunnelblick"
  "vlc"
  "webpquicklook"
)

## make some directories
mkdir_with_ln "$HOME/util" "$HOME/u"
mkdir_with_ln "$HOME/personal" "$HOME/p"
mkdir_with_ln "$HOME/workspace" "$HOME/w"
mkdir -p "$HOME/tmp"

## command line tools
# TODO need to somehow wait for this install to finish
xcode-select -p 1>/dev/null || xcode-select --install

## System Prefs
defaults write com.apple.dock workspaces-auto-swoosh -bool NO
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
mkdir -p ~/screenshots
defaults write com.apple.screencapture location ~/screenshots/

## Install homebrew
hash brew || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap caskroom/cask
brew tap caskroom/fonts

# Install each of the homebrew packages in the list
for package in "${brewlist[@]}"; do
  brew install "$package"
done

# Install each of the homebrew casks in the list
for cask in "${brewcasklist[@]}"; do
  brew cask install "$cask"
done

# fetch personal dotfiles
if [ ! -d ~/personal/dotfiles ]; then
  git clone ssh://git@gitlab.dmartinez.net:61222/dmartinez/dotfiles.git ~/personal/dotfiles
  ( cd ~/personal/dotfiles ; ./deploy.sh )
fi

## vim (just in case)
if [ ! -d ~/.vim_runtime ]; then
 git clone https://github.com/amix/vimrc.git ~/.vim_runtime
 sh ~/.vim_runtime/install_awesome_vimrc.sh
fi

## emacs
if [ ! -d ~/.cask ]; then
  git clone https://github.com/cask/cask ~/.cask
fi

if [ ! -d ~/personal/dotemacs ]; then
  git clone ssh://git@gitlab.dmartinez.net:61222/dmartinez/dotfiles.git ~/personal/dotemacs
  ln -sf ~/personal/dotemacs/.emacs.d ~/.emacs.d
  ( cd ~/.cask ; bin/cask install )
  # Yes, it takes repeated tries for some reason.
  ( cd ~/.emacs.d ; ~/.cask/bin/cask install ; ~/.cask/bin/cask install ; ~/.cask/bin/cask install )
fi

## versions of stuff
asdf plugin-add elixir
asdf plugin-add erlang
asdf plugin-add ruby
asdf plugin-add python https://github.com/danhper/asdf-python.git
asdf plugin-add rust https://github.com/code-lever/asdf-rust
asdf plugin-add go https://github.com/kennyp/asdf-golang
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin-add lua https://github.com/Stratus3D/asdf-lua.git

# add gpg keys for node packages
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
latest_node=$(asdf list-all nodejs | tail -n 1)
asdf install nodejs "$latest_node"
asdf global nodejs "$latest_node"
npm install -g vmd

# install a MRI / C-based ruby
latest_ruby=$(asdf list-all ruby | grep ^[0-9] | grep -v dev | tail -n 1)
asdf install ruby "$latest_ruby"
asdf global ruby "$latest_ruby"
gem install tmuxinator

# install a newish c-python
latest_python3=$(asdf list-all python | grep ^3 | grep -v dev | tail -n 1)
latest_python2=$(asdf list-all python | grep ^2 | grep -v dev | tail -n 1)
LDFLAGS="-L/usr/local/opt/zlib/lib" CPPFLAGS="-I/usr/local/opt/zlib/include" asdf install python "$latest_python3"
LDFLAGS="-L/usr/local/opt/zlib/lib" CPPFLAGS="-I/usr/local/opt/zlib/include" asdf install python "$latest_python2"
asdf global python "$latest_python3" "$latest_python2"
asdf reshim python
PIP_REQUIRE_VIRTUALENV='' pip3 install --user mdv pipenv

## Restart some things
killall Dock
killall SystemUIServer

## Add some more readline shortuvst
mkdir -p ~/Library/KeyBindings
curl -o \
     ~/Library/KeyBindings/DefaultKeyBinding.dict \
     https://gist.githubusercontent.com/cheapRoc/9670905/raw/1c1cd2e84daf07c9a4c8de0ff86d1baf75d858c6/EmacsKeyBinding.dict

## require password ... keep these last
sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh
brew cask install karabiner-elements
