#!/bin/bash

# Ref: https://aws.amazon.com/premiumsupport/knowledge-center/ec2-linux-log-user-data/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Update packages
yum update -y

# Upgrade AWS CLI to V2
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install git
yum install -y git

# Install Docker
amazon-linux-extras install docker
service docker start
usermod -a -G docker ec2-user
chkconfig docker on

# Install Docker Compose
pip3 install docker-compose

# Install Docker Compose (option 2)
# docker_compose_latest="https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-x86_64"
# curl -L $docker_compose_latest -o /usr/bin/docker-compose && sudo chmod 755 /usr/bin/docker-compose && docker-compose --version

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client --output=yaml

# Install kind 
# Ref: https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Test kind installation success
kind version
kind create cluster --help

# Create cluster manifest
EC2_USER_HOME=/home/ec2-user
CLUSTER_DIR=$EC2_USER_HOME/kind-basic-multi-node-cluster
mkdir $CLUSTER_DIR
cd $CLUSTER_DIR
cat - <<EOF | tee kind-basic-multi-node-cluster.yaml
# three node (two workers) cluster config
# https://kind.sigs.k8s.io/docs/user/quick-start/
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF
kind create cluster --name basic-multi-node-cluster --config kind-basic-multi-node-cluster.yaml

# Test cluster success
kubectl get nodes

# Make ready for ec2-user post ssh
chown -R ec2-user.ec2-user $CLUSTER_DIR
mv $CLUSTER_DIR/.kube $EC2_USER_HOME

reboot
