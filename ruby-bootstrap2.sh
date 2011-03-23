#!/bin/bash -ex

# redirecting output 
# http://alestic.com/2010/12/ec2-user-data-output
#exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade

apt-get -y install git

# For CC compiler of ruby
apt-get -y install build-essential

# no such file to load -- zlib (LoadError)
# http://stackoverflow.com/questions/2441248/rvm-ruby-1-9-1-troubles
apt-get install -y zlib1g-dev libssl-dev libreadline5-dev libxml2-dev libsqlite3-dev

> /tmp/base-finished

#/.rvm/src/rvm/scripts/install: line 243: HOME: unbound variable
HOME="/root"
export HOME

# RVM
# http://rvm.beginrescueend.com/
#bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-head )
bash < <( curl -L http://bit.ly/rvm-install-system-wide )

echo ". /usr/local/rvm" >> /etc/profile.d/rvm-system-wide

#
#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
. /usr/local/rvm/scripts/rvm

rvm install 1.9.2
rvm use 1.9.2 --default

