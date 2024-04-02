#!/bin/bash

sudo apt-get update
sudo apt-get install -y docker.io

sudo systemctl enable docker
sudo systemctl start docker

echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin

sudo docker pull $DOCKER_USERNAME/spring-pet-clinic:latest

sudo docker run -d --name spring-petclinic -p 80:8080 $DOCKER_USERNAME/spring-pet-clinic:latest
