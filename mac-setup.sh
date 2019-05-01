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

  if [ ! -f "$2" ]; then
    ln -s "$1" "$2"
  fi
}

declare -a brewlist=(
  "ag"
  "asdf"
  "bash"
  "bat"
  "coreutils"
  "diff-so-fancy"
  "fasd"
  "fd"
  "fzf"
  "git"
  "jq"
  "openssh"
  "pwgen"
  "sirens"
  "tmux"
  "tree"
  "vim"
  "zsh"
)

declare -a brewcasklist=(
  "alfred"
  "appcleaner"
  "betterzip"
  "caffeine"
  "docker"
  "dropbox"
  "emacs"
  "firefox"
  "flux"
  "font-anonymous-pro"
  "font-dejavu-sans-mono-for-powerline"
  "font-droidsansmono-nerd-font font-droid-sans-mono-for-powerline"
  "font-inconsolata font-inconsolata-for-powerline"
  "font-liberation-sans"
  "font-liberationmono-nerd-font font-liberation-mono-for-powerline"
  "font-meslo-lg font-input"
  "font-meslo-lg"
  "font-nixie-one"
  "font-office-code-pro"
  "font-pt-mono"
  "font-raleway font-roboto"
  "font-source-code-pro font-source-code-pro-for-powerline"
  "font-source-sans-pro"
  "google-chrome"
  "hammerspoon"
  "insomnia"
  "iterm2"
  "qlcolorcode"
  "qlmarkdown"
  "qlprettypatch"
  "qlstephen"
  "quicklook-csv"
  "quicklook-json"
  "slack"
  "spectacle"
  "superduper"
  "suspicious-package"
  "vlc"
  "webpquicklook"
)

## make some directories
mkdir_with_ln "~/util" "~/u"
mkdir_with_ln "~/personal" "~p"
mkdir_with_ln "~/workspace" "~/w"
mkdir -p ~/bin
mkdir -p ~/tmp

## command line tools
xcode-select --install

## System Prefs
defaults write com.apple.dock workspaces-auto-swoosh -bool NO
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
mkdir ~/screenshots
defaults write com.apple.screencapture location ~/screenshots/

## Install homebrew
usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap caskroom/cask
brew tap caskroom/fonts

for package in "${brewlist[@]}"; do
  brew install "$package"
done

for cask in "${brewcasklist[@]}"; do
  brew cask install "$cask"
done

# oh-my-zsh
git clone https://github.com/robbyrussell/oh-my-zsh ~/.oh-my-zsh

# fetch personal dotfiles
git clone ssh://git@gitlab.dmartinez.net:61222/dmartinez/dotfiles.git ~/personal/dotfiles
( cd ~/personal/dotfiles ; ./deploy.sh )

## vim (just in case)
git clone https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

## emacs
git clone https://github.com/cask/cask ~/.cask
git clone ssh://git@gitlab.dmartinez.net:61222/dmartinez/dotfiles.git ~/personal/dotemacs
ln -s ~/personal/dotemacs ~/.emacs.d/
( cd ~/.cask ; bin/cask install )
# Yes, it takes repeated tries for some reason.
( cd ~/.emacs.d ; ~/.cask/bin/cask install ; ~/.cask/bin/cask install ; ~/.cask/bin/cask install )

## versions of stuff
asdf plugin-add elixir
asdf plugin-add erlang
asdf plugin-add ruby
asdf plugin-add python https://github.com/danhper/asdf-python.git
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin-add rust https://github.com/code-lever/asdf-rust

## Restart some things
killall Dock
killall SystemUIServer

## requires password / interaction (but doesn't seem to work anymore)
chsh -s $(which zsh) $(whoami)
