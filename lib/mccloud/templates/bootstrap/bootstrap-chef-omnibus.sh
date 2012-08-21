#!/bin/bash -ex

# download omnibus install.sh
if which curl 2>/dev/null; then
    curl -L http://opscode.com/chef/install.sh | sudo bash
else
    wget -q -O - http://opscode.com/chef/install.sh | sudo bash
fi