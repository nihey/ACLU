#!/bin/bash
# Install Code Depoy Agent (http://docs.aws.amazon.com/codedeploy/latest/userguide/codedeploy-agent-operations-install-ubuntu.html)
apt-get update

apt-get install ruby wget python awscli -y

# Upgrade awscli to latest version (https://github.com/aws/aws-cli/issues/1926)
pip install --upgrade awscli

cd /home/ubuntu

wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install

chmod +x ./install

./install auto

service codedeploy-agent start

# Install Cloudwatch Logs Agent so we can see CodeDeploy logs in CloudWatch (https://aws.amazon.com/blogs/devops/view-aws-codedeploy-logs-in-amazon-cloudwatch-console/)
wget https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py

wget https://s3.amazonaws.com/aws-codedeploy-us-east-1/cloudwatch/codedeploy_logs.conf

chmod +x ./awslogs-agent-setup.py

sudo python awslogs-agent-setup.py -n -r us-east-1 -c s3://aws-codedeploy-us-east-1/cloudwatch/awslogs.conf

mkdir -p /var/awslogs/etc/config

cp codedeploy_logs.conf /var/awslogs/etc/config/

service awslogs restart

# Black magic!!! this script requires variables generated by TF during provisioning
# Set ENV variables received by TF during deployment
sudo chmod ugo+rx /etc/profile
echo export ECR_REGION=${ECR_REGION}  >> /etc/profile
echo export IMAGES_REPO_URL=${IMAGES_REPO_URL}  >> /etc/profile
echo export IMAGES_REPO_NAME=${IMAGES_REPO_NAME}  >> /etc/profile

# Install libraries required for aclu project
export JQ_VERSION=1.5 # latest jq version as of 15-Aug-2015
export DOCKER_COMPOSE_VERSION=1.15.0

# Install and update required libraries (python, httpie, and gdal are used for importer...we may be able to remove then later)
sudo apt-get install -y \
     httpie \
     gdal-bin

# install ./jq (https://stedolan.github.io/jq/)
sudo wget -O /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-$JQ_VERSION/jq-linux64
sudo chmod a+x /usr/local/bin/jq

# used convenience scripts since this is just test
# https://docs.docker.com/engine/installation/linux/docker-ce/debian/#install-using-the-convenience-script
sudo wget -qO- https://get.docker.com/ | sudo sh

# download docker-compose
sudo wget -O /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/run.sh
sudo chmod a+x /usr/local/bin/docker-compose
# Add r and x permissions to ubuntu user...
sudo usermod -aG docker ubuntu