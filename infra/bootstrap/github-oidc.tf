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
  description = "Complete permissions for CI/CD + Terraform lifecycle"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

  ####################################
  # ECR – COMPLETE LIFECYCLE (Terraform + Docker)
  ####################################
  {
    Effect = "Allow"
    Action = [
      "ecr:GetAuthorizationToken",

      "ecr:CreateRepository",
      "ecr:DescribeRepositories",
      "ecr:DeleteRepository",

      "ecr:ListImages",
      "ecr:BatchDeleteImage",

      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",

      "ecr:ListTagsForResource",
      "ecr:TagResource",
      "ecr:UntagResource",

      "ecr:GetRepositoryPolicy",
      "ecr:SetRepositoryPolicy"
    ]
    Resource = "*"
  },

  ####################################
  # IAM (LIMITED TO autoops-* ROLES)
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
# APP RUNNER – COMPLETE TERRAFORM LIFECYCLE
####################################
{
  Effect = "Allow"
  Action = [
    # Service lifecycle
    "apprunner:CreateService",
    "apprunner:DeleteService",
    "apprunner:DescribeService",
    "apprunner:UpdateService",
    "apprunner:ListServices",
    "apprunner:StartDeployment",
    "apprunner:PauseService",
    "apprunner:ResumeService",
    "apprunner:ListOperations",
    "apprunner:DescribeOperation",

    # Tagging (REQUIRED FOR TERRAFORM)
    "apprunner:ListTagsForResource",
    "apprunner:TagResource",
    "apprunner:UntagResource"
  ]
  Resource = "*"
},

  ####################################
  # CLOUDWATCH
  ####################################
  {
    Effect = "Allow"
    Action = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
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
