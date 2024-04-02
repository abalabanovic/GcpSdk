#!/bin/bash

#DOCKER_PASSWORD && DOCKER_USERNAME
echo "Did you provide docker credentials in env?[y/n]"
read answer

if [ "$answer" = "y" ]; then
	echo "Starting script..."
	sleep 1
elif [ "$answer" = "n" ]; then
	echo "Please provide credentials! DOCKER_PASSWORD && DOCKER USERNAME" 
	echo "Exiting ..."
	sleep 2
	exit 1
else
	echo "Wrong input!!Please try again!!"
	exit 1

fi

#Service account key
gcloud auth activate-service-account --key-file=/home/osboxes/Downloads/gcp-key.json

#define values
VPC_NAME="vpc-andrej"
SUBNET_NAME="custom-subnet"
REGION="us-central1"
SUBNET_IP="10.0.1.0/24"

#Create VPC network with custom subnet
gcloud compute networks create $VPC_NAME --subnet-mode=custom

#Creat subnet for VPC
gcloud compute networks subnets create $SUBNET_NAME \
--network=$VPC_NAME \
--region=$REGION \
--range=$SUBNET_IP

echo "VPC and Subnet created succesfully"

#Create firewall rules for VPC

gcloud compute firewall-rules create allow-ssh-traffic \
--network=$VPC_NAME \
--allow=tcp:22 \
--source-ranges=0.0.0.0/0

gcloud compute firewall-rules create allow-http-traffic \
--network=$VPC_NAME \
--allow=tcp:80 \
--source-ranges=0.0.0.0/0 \
--target-tags=http-server

echo "Firewall rules created!"

gcloud services enable containerregistry.googleapis.com

GCR_NAME="spring-pet-clinic"
PROJECT_NAME=$(gcloud config get-value project)


gcloud artifacts repositories create $GCR_NAME \
--repository-format=docker \
--location=$REGION

echo "Artifact repository created"

#gcloud auth configure-docker $REGION-docker.pkg.dev

#DOCKER_REPO="$REGION-docker.pkg.dev/$PROJECT_NAME/$GCR_NAME/spring-pet-clinic:latest"
#sudo docker build -t $DOCKER_REPO .
#sudo docker push $DOCKER_REPO

Create bucket and copy script to the bucket
gsutil mb -p gd-gcp-internship-devops gs://my-startup-scripts/
gsutil cp /home/osboxes/spring-petclinic/startup-script.sh gs://my-startup-scripts/startup-script.sh
echo "Bucket created and script is copied to bucket!"

#Create instance inside vpc that will run startup-script from bucket
#Startup script installs docker,login to dh and run container with image
gcloud compute instances create spring-web \
--machine-type=e2-micro \
--subnet=$SUBNET_NAME \
--zone="$REGION-a" \
--tags=http-server \
--metadata-from-file env=<(env) \
--metadata startup-script-url=gs://my-startup-scripts/startup-script.sh

# Echo public ip
gcloud compute instances describe spring-web --zone="$REGION-a" --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

