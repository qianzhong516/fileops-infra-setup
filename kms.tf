resource "aws_kms_alias" "sops_key_alias" {
  name          = "alias/fileops-dev"
  target_key_id = aws_kms_key.sops_key.key_id
}

# Master key for encrypting Kubernetes secrets
resource "aws_kms_key" "sops_key" {
  description             = "An symmetric encryption KMS key for SOPs"
  enable_key_rotation     = true
  deletion_window_in_days = 20
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::665303624691:role/tf_oidc_role", "arn:aws:iam::665303624691:user/eks-training-admin"
          ]
        },
        Action   = "kms:*"
        Resource = "*"
      },
      # {
      #   Sid    = "Allow administration of the key"
      #   Effect = "Allow"
      #   Principal = {
      #     AWS = "arn:aws:iam::665303624691:user/eks-training-admin"
      #   },
      #   Action = [
      #     "kms:ReplicateKey",
      #     "kms:Create*",
      #     "kms:Describe*",
      #     "kms:Enable*",
      #     "kms:List*",
      #     "kms:Put*",
      #     "kms:Update*",
      #     "kms:Revoke*",
      #     "kms:Disable*",
      #     "kms:Get*",
      #     "kms:Delete*",
      #     "kms:ScheduleKeyDeletion",
      #     "kms:CancelKeyDeletion"
      #   ],
      #   Resource = "*"
      # }
    ]
  })
  tags = merge(local.tags, {
    Name        = "fileops-sops-master-key"
    Environment = "dev"
  })
}
