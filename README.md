# FileOps Infrastructure Setup

This repo contains the one-time-run setup code and it completes the following tasks:

- Set up an S3 bucket for storing Terraform states remotely
- Set up the ECR private repos for storing multi-architecture images
- Add GitHub OIDC provider to IAM
- Add a role assumed by OIDC identity to perform AWS actions
- Set up HCP Terraform OIDC to perform AWS actions
- Set up a KMS key for SOPS

## Setup Instructions

- Set up a Team Token in HCP Terraform to input for the variable `tfe_token`. It's required for fetching your target workspace's ID.
