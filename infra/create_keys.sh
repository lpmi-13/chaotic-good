if [ -d "./ansible" ]
  then
    ssh-keygen -t ed25519 -o -a 100 -f ansible/terraform.ed25519 -N ""
  else
    mkdir ansible
    ssh-keygen -t ed25519 -o -a 100 -f ansible/terraform.ed25519 -N ""
fi
