#!/bin/sh

# we set up the temporary credentials first
assume

# and now we build and push
docker build -t chaotic-backend .

aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 992382835938.dkr.ecr.eu-west-1.amazonaws.com

docker tag chaotic-backend:latest 992382835938.dkr.ecr.eu-west-1.amazonaws.com/chaotic-backend

docker push 992382835938.dkr.ecr.eu-west-1.amazonaws.com/chaotic-backend
