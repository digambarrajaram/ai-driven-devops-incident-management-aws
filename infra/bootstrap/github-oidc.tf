############################################
# GitHub OIDC Provider (Account-wide)
############################################

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

############################################
# IAM Role for GitHub Actions (OIDC)
############################################

resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-autoops-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:digambarrajaram/ai-driven-devops-incident-management-aws:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

############################################
# CloudWatch (logs & metrics for CI)
############################################

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

############################################
# Custom Policy: Terraform CI Permissions
############################################

resource "aws_iam_policy" "terraform_ci_policy" {
  name        = "github-actions-terraform-autoops"
  description = "Terraform apply/destroy permissions for AutoOps CI/CD"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      ####################################
      # ECR (repo + image lifecycle)
      ####################################
      {
        Effect = "Allow"
        Action = [
          "ecr:CreateRepository",
          "ecr:DescribeRepositories",
          "ecr:DeleteRepository",
          "ecr:ListImages",
          "ecr:BatchDeleteImage",
          "ecr:PutImageScanningConfiguration",
          "ecr:TagResource"
        ]
        Resource = "*"
      },

      ####################################
      # IAM (ONLY autoops roles)
      ####################################
      {
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PassRole"
        ]
        Resource = "arn:aws:iam::*:role/autoops-*"
      },

      ####################################
      # App Runner
      ####################################
      {
        Effect = "Allow"
        Action = [
          "apprunner:*"
        ]
        Resource = "*"
      },

      ####################################
      # CloudWatch (metrics & alarms)
      ####################################
      {
        Effect = "Allow"
        Action = [
          "logs:*",
          "cloudwatch:*"
        ]
        Resource = "*"
      }
    ]
  })
}

############################################
# Attach Terraform CI Policy
############################################

resource "aws_iam_role_policy_attachment" "terraform_ci_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.terraform_ci_policy.arn
}

############################################
# Custom Policy: Terraform Backend Access
############################################

resource "aws_iam_policy" "terraform_backend_policy" {
  name        = "github-actions-terraform-backend"
  description = "Terraform remote backend access (S3 + DynamoDB)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      ####################################
      # S3 backend bucket
      ####################################
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::autoops-terraform-state-605134452604"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::autoops-terraform-state-605134452604/*"
      },

      ####################################
      # DynamoDB state locking
      ####################################
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = "arn:aws:dynamodb:us-east-1:605134452604:table/terraform-locks"
      }
    ]
  })
}

############################################
# Attach Backend Policy
############################################

resource "aws_iam_role_policy_attachment" "terraform_backend_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.terraform_backend_policy.arn
}
