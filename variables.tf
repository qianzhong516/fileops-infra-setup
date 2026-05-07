locals {
  github_org    = "qianzhong516"
  github_repo   = "fileops"
  github_branch = "main"
  account_id    = data.aws_caller_identity.current.account_id
  tags = {
    Name = "FileOps"
  }
}
