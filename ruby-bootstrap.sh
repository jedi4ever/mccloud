#!/bin/bash -ex

apt-get update
apt-get -y install ruby ruby-dev libopenssl-ruby rdoc ri irb build-essential wget ssl-cert
cd /tmp
test ! -f rubygems-1.3.7 && wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz
test -f rubygems-1.3.7.tgz && tar zxf rubygems-1.3.7.tgz
cd rubygems-1.3.7 && ruby setup.rb --no-format-executable
gem install chef --no-ri --no-rdoc
gem install puppet --no-ri --no-rdoc

