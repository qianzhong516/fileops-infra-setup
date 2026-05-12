// Reference: https://www.hashicorp.com/en/blog/access-aws-from-hcp-terraform-with-oidc-federation

// Create HCP Terraform OIDC provider 
data "tls_certificate" "provider" {
  url = "https://app.terraform.io"
}

resource "aws_iam_openid_connect_provider" "hcp_terraform" {
  url = "https://app.terraform.io"

  client_id_list = [
    "aws.workload.identity", # Default audience in HCP Terraform for AWS.
  ]

  thumbprint_list = [
    data.tls_certificate.provider.certificates[0].sha1_fingerprint,
  ]
}

// Create an IAM role that HCP Terraform will assume at runtime
data "aws_iam_policy_document" "oidc_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.hcp_terraform.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "app.terraform.io:aud"
      values   = ["aws.workload.identity"]
    }

    condition {
      test     = "StringLike"
      variable = "app.terraform.io:sub"
      values   = ["organization:${var.tfc_org_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:*"]
    }
  }
}

resource "aws_iam_role" "tf_oidc_role" {
  name               = "tf_oidc_role"
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_policy.json
}

// Grant the role permissions
data "aws_iam_policy" "admin_access" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "admin_access" {
  policy_arn = data.aws_iam_policy.admin_access.arn
  role       = aws_iam_role.tf_oidc_role.name
}

// Set HCP Terraform env vars in the workspace: TFC_AWS_PROVIDER_AUTH and TFC_AWS_RUN_ROLE_ARN
data "tfe_workspace" "this" {
  name         = var.tfc_workspace_name
  organization = var.tfc_org_name
}

resource "tfe_variable" "tfc_aws_provider_auth" {
  key          = "TFC_AWS_PROVIDER_AUTH"
  value        = "true"
  category     = "env"
  workspace_id = data.tfe_workspace.this.id
}

resource "tfe_variable" "tfc_role_arn" {
  sensitive    = true
  key          = "TFC_AWS_RUN_ROLE_ARN"
  value        = aws_iam_role.tf_oidc_role.arn
  category     = "env"
  workspace_id = data.tfe_workspace.this.id
}
