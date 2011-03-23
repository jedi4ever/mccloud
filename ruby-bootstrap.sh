#!/bin/bash -ex

sudo apt-get update
sudo apt-get -y install ruby ruby-dev libopenssl-ruby rdoc ri irb build-essential wget ssl-cert
cd /tmp
wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz
tar zxf rubygems-1.3.7.tgz
cd rubygems-1.3.7
sudo ruby setup.rb --no-format-executable
sudo gem install chef

