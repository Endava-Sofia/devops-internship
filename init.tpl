#!/bin/bash

#curl s3://${bucket_name}/${key_name}
#s3://endava-devops-intern-bg/my_bucket_key

#bucket = ${bucket_name}
#wget https://endava-devops-intern-bg.s3.amazonaws.com/my_bucket_key  

#wget https://${bucket_name}.s3.amazonaws.com/${key_name}


sudo apt-get update
sudo apt install -y awscli

#aws s3 cp s3://endava-devops-intern-bg/my_bucket_key ~
aws s3 cp s3://${bucket_name}/${key_name} /tmp/files_from_S3