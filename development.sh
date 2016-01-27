#!/bin/bash

#
# WTH specific installs
# - - - - - - - - - - - - - -  

set -e

brewInstalls=(mongodb26 php53 php53-oauth php53-mcrypt mysql56)



# tap versions
[[ ! $(brew tap | grep "homebrew/versions") ]] &&
(
  log "brew tap homebrew/versions"
  brew tap homebrew/versions
)

# tap php
[[ ! $(brew tap | grep "homebrew/php") ]] &&
(
  log "brew tap homebrew/php"
  brew tap homebrew/php
)

# install brew programs
for app in "${brewInstalls[@]}"; do
  [[ $(brew info $app | grep "Not installed") ]] &&
  (
    log "brew install $app"
    brew install $app
   ) || echo " - $app already installed"
done

# set up mongo to run at start
mkdir -p ~/Library/LaunchAgents
ln -sfv /usr/local/opt/mongodb26/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb26.plist

# set up mysql to run at start
ln -sfv /usr/local/opt/mysql56/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql56.plist

# copy apache config if it's not there
[ ! -f /private/etc/apache2/other/httpd-waytohealth.conf ] &&
(
  sudo cp httpd.conf /private/etc/apache2/other/httpd-waytohealth.conf
) || log "Apache already configured"

# copy php config if it's not there
[ ! -f /usr/local/etc/php/5.3/conf.d/ ] &&
(
  sudo cp php.ini /usr/local/etc/php/5.3/conf.d/waytohealth.ini
) || log "PHP already configured"

#restart apache
sudo apachectl restart

#TODO: SET @@global.sql_mode= '';
#TODO: sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION 

#TODO: 127.0.0.1 waytohealth


