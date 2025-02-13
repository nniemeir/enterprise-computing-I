#!/bin/bash

# Install Ansible
python3 -m pip install --user ansible-core

# Install Ansible's POSIX collection
ansible-galaxy collection install ansible.posix

# Generate an SSH key pair
ssh-keygen -b 4096 -t rsa
