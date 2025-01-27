#!/bin/bash

#
# ssh host key generation
#
# https://www.cyberciti.biz/faq/howto-regenerate-openssh-host-keys/
#
#

# delete files on your SSHD server
rm -v /etc/ssh/ssh_host_*

# create a new set of keys on your SSHD server
dpkg-reconfigure openssh-server

# restart ssh server
systemctl restart ssh

echo "New host keys generated, login again!"