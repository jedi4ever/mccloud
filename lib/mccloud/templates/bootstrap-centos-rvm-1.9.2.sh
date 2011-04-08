#!/bin/bash -ex

yum install -y bash curl git
bash < <(curl -s -B https://rvm.beginrescueend.com/install/rvm)
yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel lib
yaml-devel libffi-devel openssl-devel
source /usr/local/rvm/scripts/rvm
rvm install ruby-1.9.2
rvm use 1.9.2 --default

gem install chef --no-ri --no-rdoc
gem install puppet --no-ri --no-rdoc
