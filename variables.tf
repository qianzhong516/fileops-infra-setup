variable "tfc_org_name" {
  default = "janice-zhong"
}

variable "tfc_project_name" {
  default = "FileOps"
}

variable "tfc_workspace" {
  default = {
    cluster         = "janice-zhong-fileops-cluster"
    platform_addons = "janice-zhong-fileops-platform-addons"
    workloads       = "janice-zhong-fileops-workloads"
    data            = "janice-zhong-fileops-data"
  }
}

variable "tfe_token" {
  type      = string
  sensitive = true
}

variable "git_ssh_private_key" {
  type      = string
  sensitive = true
}

locals {
  github_org    = "qianzhong516"
  github_repo   = "fileops"
  github_branch = "main"
  account_id    = data.aws_caller_identity.current.account_id
  condition_values = [
    for _, workspace_name in var.tfc_workspace :
    "organization:${var.tfc_org_name}:project:${var.tfc_project_name}:workspace:${workspace_name}:run_phase:*"
  ]
  tags = {
    Name = "FileOps"
  }
}
