data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state_storage" {
  bucket = "fileops-setup-tf-states"

  tags = local.tags
}

resource "aws_s3_bucket_versioning" "enable_s3_versioning" {
  bucket = aws_s3_bucket.terraform_state_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_ecr_repository" "fileops_frontend" {
  name                 = "fileops-frontend"
  image_tag_mutability = "MUTABLE"

  tags = local.tags
}

resource "aws_ecr_repository" "fileops_backend" {
  name                 = "fileops-backend"
  image_tag_mutability = "MUTABLE"

  tags = local.tags
}

/**
 * ===================================================
 * Allow GitHub CI to upload container images to ECR 
 * ===================================================
**/

resource "aws_iam_openid_connect_provider" "default" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  tags = local.tags
}

resource "aws_iam_role" "git_role" {
  name = "fileops-git-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = aws_iam_openid_connect_provider.default.arn
        }
        Condition = {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub" : "repo:${local.github_org}/${local.github_repo}:ref:refs/heads/${local.github_branch}"
          }
        }
      },
    ]
  })

  tags = local.tags
}


resource "aws_iam_role_policy" "permission_policy" {
  name = "fileops-git-permissions"
  role = aws_iam_role.git_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EcrReadForPushAndManifestChecks",
        Effect = "Allow",
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeImages",
          "ecr:ListImages"
        ],
        Resource = [
          "arn:aws:ecr:ap-southeast-2:${local.account_id}:repository/fileops-frontend",
          "arn:aws:ecr:ap-southeast-2:${local.account_id}:repository/fileops-backend"
        ]
      },
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ecr:ap-southeast-2:${local.account_id}:repository/fileops-frontend",
          "arn:aws:ecr:ap-southeast-2:${local.account_id}:repository/fileops-backend",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "ecr:GetAuthorizationToken",
        "Resource" : "*"
      }
    ]
  })
}

