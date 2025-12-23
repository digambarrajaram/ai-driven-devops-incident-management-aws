############################################
# GitHub OIDC Provider (Account-wide)
############################################

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

############################################
# IAM Role for GitHub Actions
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
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:digambarrajaram/ai-driven-devops-incident-management-aws:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

############################################
# Permissions for CI/CD
############################################

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "apprunner" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSAppRunnerFullAccess"
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

############################################
# Custom policy for Terraform (CI/CD)
############################################

resource "aws_iam_policy" "terraform_ci_policy" {
  name        = "github-actions-terraform-autoops"
  description = "Permissions required by Terraform running in GitHub Actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ECR (for Terraform + CI)
      {
        Effect = "Allow"
        Action = [
          "ecr:CreateRepository",
          "ecr:DescribeRepositories",
          "ecr:PutImageScanningConfiguration",
          "ecr:TagResource"
        ]
        Resource = "*"
      },

      # IAM (ONLY for autoops roles)
      {
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PassRole"
        ]
        Resource = "arn:aws:iam::*:role/autoops-*"
      },

      # App Runner
      {
        Effect = "Allow"
        Action = [
          "apprunner:*"
        ]
        Resource = "*"
      },

      # CloudWatch
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
# Attach policy to GitHub Actions role
############################################

resource "aws_iam_role_policy_attachment" "terraform_ci_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.terraform_ci_policy.arn
}
