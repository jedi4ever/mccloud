#!/bin/bash -ex

apt-get update
apt-get -y install libopenssl-ruby  build-essential wget ssl-cert

bash < <(curl -s -B https://rvm.beginrescueend.com/install/rvm)
source /usr/local/rvm/scripts/rvm

rvm install 1.8.7
rvm use 1.8.7 --default

gem install chef --no-ri --no-rdoc
gem install puppet --no-ri --no-rdoc

