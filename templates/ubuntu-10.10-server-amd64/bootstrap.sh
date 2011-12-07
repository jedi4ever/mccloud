#!/bin/bash -e

apt-get update
apt-get -y install ruby ruby-dev libopenssl-ruby rdoc ri irb build-essential wget ssl-cert
cd /tmp
test ! -f rubygems-1.3.7.tgz && wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz
test -f rubygems-1.3.7.tgz && tar zxf rubygems-1.3.7.tgz

gem --version |grep 1.3.7 | wc -l |grep 0 && cd rubygems-1.3.7 && ruby setup.rb --no-format-executable

gem list chef|grep chef|wc -l | grep 0 && gem install chef --no-ri --no-rdoc
gem list puppet|grep puppet|wc -l | grep 0 && gem install puppet --no-ri --no-rdoc

useradd puppet

echo "bootstrap finished"
