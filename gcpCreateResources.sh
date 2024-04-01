#!/bin/bash

gcloud auth activate-service-account --key-file=/home/osboxes/Downloads/gcp-key.json
echo "Enter VPC name:"
read vpc_name
gcloud compute networks create $vpc_name --subnet-mode=auto
