variable "tfc_org_name" {
  default = "janice-zhong"
}

variable "tfc_project_name" {
  default = "FileOps"
}

variable "eks_tfc_workspace_name" {
  default = "janice-zhong-fileops"
}

variable "workload_tfc_workspace_name" {
  default = "janice-zhong-fileops-workload-configs"
}

variable "tfe_token" {
  type      = string
  sensitive = true
}

locals {
  github_org    = "qianzhong516"
  github_repo   = "fileops"
  github_branch = "main"
  account_id    = data.aws_caller_identity.current.account_id
  tags = {
    Name = "FileOps"
  }
}
