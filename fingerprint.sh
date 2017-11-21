#!/bin/bash

### Don't modify unles you know what you'r doing

# Here we generate rsa key for our container
ssh-keygen -t rsa -b 4096 -N "" -f "/root/.ssh/id_rsa" -q

# Get MD5 has from public key
KEY=`ssh-keygen -E md5 -lf /root/.ssh/id_rsa.pub | awk '{print $2}'`

# Strip md5: from string
FINGERPRINT=${KEY//MD5:}

# Set MD5 hash in terraform variable file
sed -i -e "s/fingerprint_md5/$FINGERPRINT/g" /go/terraform.tfvars
