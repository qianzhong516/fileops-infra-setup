# FileOps Infrastructure Setup

This repo contains the one-time-run setup code and it completes the following tasks:

- Set up an S3 bucket for storing Terraform states remotely
- Set up the ECR private repos for storing multi-architecture images
- Add GitHub OIDC provider to IAM
- Add a role assumed by OIDC identity to perform AWS actions
