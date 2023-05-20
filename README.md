# A Docker and KIND Ready Amazon EC2 Node
For step by step instruction on how to use this code repo, please visit the associated blog post- [The AWS Way — IaC in Action — A Docker and KIND Ready Amazon EC2 Node](https://medium.com/the-aws-way/the-aws-way-iac-in-action-a-docker-and-kind-ready-amazon-ec2-node-a0e2d907f9ec)

##  Three essential commands to get started. For more see blog above.
```
# Make sure 'aws configure' has run and connectivity to AWS account is working.
REPO=terraform-ec2-with-docker-and-kind && \
    rm -rf $REPO \
    git clone https://github.com/jdluther2020/$REPO.git && \
    cd $REPO

terraform init && terraform apply -auto-approve -var my_ip=$(curl -s ifconfig.me)

# Final clearn up step
terraform apply -destroy -var my_ip=$(curl -s ifconfig.me)
```

Thank you for stopping by!

JDL
