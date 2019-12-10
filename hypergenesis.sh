#!/bin/bash

set -e

#
#             Configuration
# - - - - - - - - - - - - - - - - - - - - - -

brewInstalls=(git grc brew-cask coreutils ack findutils gnu-tar tmux htop-osx ctags nginx gnu-sed nmap tree wget watch imagemagick terminal-notifier bash-completion)

dotfiles_repo='git@github.com:benirose/dotfiles.git'
dotfiles_location="$HOME/.dotfiles"

nodeVersion='8'
rubyVersion='2.0'

# Node apps to npm install -g
nodeGlobalModules=(bunyan ummon)

# Apps to install
brewCaskInstalls=(spotify alfred dropbox sublime-text firefox vlc qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql)

#
#     Functions make things easier!
# - - - - - - - - - - - - - - - - - - - - - -

log() {
  echo ""
  echo " ==> $1"
  echo ""
}

#
#         Commence Installations
# - - - - - - - - - - - - - - - - - - - - - -

#if [[ ! $(pkgutil --pkg-info=com.apple.pkg.DeveloperToolsCLI) ]]; then
#  xcode-select --install
#
#  echo "ERROR: XCode command line tools are NOT installed. The install should popup now. Retart your terminal when complete. Exiting..."
#  echo ""
#  echo "If you need help installing, go to http://stackoverflow.com/a/9329325/109589"
#  exit 1
#fi

echo ''
echo '       * * * * * * * * * * * * * * INITIATING * * * * * * * * * * * * * * '
echo''
echo '	    __  __                                                  '
echo '	   / / / /_  ______  ___  _______                           '
echo '	  / /_/ / / / / __ \/ _ \/ _____/                     _     '
echo '	 / __  / /_/ / /_/ /  __/ / ____/__  ____  ___  _____(_)____'
echo '	/_/ /_/\__, / .___/\___/_/ / __/ _ \/ __ \/ _ \/ ___/ / ___/'
echo '	      /____/_/          / /_/ /  __/ / / /  __(__  ) (__  ) '
echo '	                        \____/\___/_/ /_/\___/____/_/____/  '
echo ''
echo '       * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * '
echo ''
echo 'This script will do the following:'
echo ''
echo '1. Install homebrew'
echo "2. brew install ${brewInstalls[*]}"
echo "3. brew cask install ${brewCaskInstalls[*]}"
echo "4. Setup your dotfiles ($dotfiles_repo) into $dotfiles_location"
echo "5. Install NVM and node.js $nodeVersion"
echo "6. npm install -g ${nodeGlobalModules[*]}"
echo "7. Install RVM and ruby $rubyVersion"
echo ''

read -p "Are you ok with this? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
echo ""

# Install homebrew
[[ ! $(which brew) ]] &&
(
  #log "Installing Homebrew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew doctor
) || log "Homebrew already installed. Updating and installing apps"

[[ ! $(brew tap | grep "caskroom/cask") ]] &&
(
  log "brew tap $app"
  brew tap homebrew/cask-cask
)

brew update

for app in "${brewInstalls[@]}"; do
  [[ $(brew info $app | grep "Not installed") ]] &&
  (
    log "brew install $app"
    brew install $app
   ) || echo " - $app already installed"
done

for app in "${brewCaskInstalls[@]}"; do
  [[ $(brew cask info $app | grep "Not installed") ]] &&
  (
    log "brew cask install $app"
    brew cask install $app
   ) || echo " - $app already installed"
done

# Reload Quicklook
qlmanage -r

# Setup dotfiles
[ ! -d $dotfiles_location ] &&
(
  log "Setting up your dotfiles repo"
  git clone $dotfiles_repo $dotfiles_location
  cd $dotfiles_location
  script/bootstrap
) || log "dotfiles already installed. Skipping..."

# Install node
[ ! -d $HOME/.nvm ] &&
(
  log "Installing NVM"
  brew install nvm
  mkdir $HOME/.nvm
  source ~/.bash_profile
  nvm install $nodeVersion
  nvm alias default $nodeVersion
) || log "NVM already installed. Installing apps..."

source ~/.bash_profile

for module in "${nodeGlobalModules[@]}"; do
  [[ -z $(npm ls -gp $module) ]] &&
  (
    log "npm install -g $module"
    npm install -g $module
  ) || echo " - $module already installed"
done


[ ! -d $HOME/.rvm ] &&
(
  log "Installing RVM"
  curl -L https://get.rvm.io | bash -s stable --ruby=$rubyVersion
) || log "RVM already installed. Skipping..."


echo "TODO: Install Chrome the old fashioned way for best reliability. Install 1Password and Slack from App Store."

echo '           ________  _            '
echo '          |_   __  |(_)           '
echo '            | |_ \_|__   _ .--.   '
echo '            |  _|  [  | [ `.-. |  '
echo '           _| |_    | |  | | | |  '
echo '          |_____|  [___][___||__] '
echo '                                  '
