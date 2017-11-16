#!/bin/bash

## Config area ## Here you have to set DigitalOcean api token

APITOKEN=""

## Config area ends ##



### Don't modify below unles you know what you'r doing

# Here we generate rsa key for our container
ssh-keygen -t rsa -b 4096 -N "" -f "/root/.ssh/id_rsa" -q

# Get MD5 has from public key
KEY=`ssh-keygen -E md5 -lf /root/.ssh/id_rsa.pub | awk '{print $2}'`

# Strip md5: from string
FINGERPRINT=${KEY//MD5:}

# Set MD5 hash in terraform variable file and api token
sed -i -e "s/fingerprint_md5/$FINGERPRINT/g" /go/terraform.tfvars
sed -i -e "s/api_key/$APITOKEN/g" /go/terraform.tfvars

# Some times rsa key takes some time to update in DigitalOcean so we sleep a while
sleep 10
