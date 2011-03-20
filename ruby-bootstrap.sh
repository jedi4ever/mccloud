#!/bin/bash -ex

echo chef chef/chef_server_url string "Noserverhere"|debconf-set-selections
apt-get install chef -y
