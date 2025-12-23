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
