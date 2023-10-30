#! /bin/bash

PUBLIC_IPS=$(terraform output | grep "," | sed -e 's/[",]//g')

for ip in $PUBLIC_IPS; do
  echo "$ip" >> ansible/hosts
done

ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/hosts --private-key ansible/terraform.ed25519 ansible/playbook.yml
