#!/usr/bin/bash

# add user ansible to be used with playbooks
useradd -m -d /home/ansible -s /bin/bash ansible
echo "Please enter new password for user ansible: "
passwd ansible

echo "Adding user ansible to sudoers: "
sudo sh -c "echo 'ansible ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
