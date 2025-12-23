
# GitHub Actions → AWS IAM Role (OIDC)

YES — GitHub CI/CD SHOULD NOT use long‑lived AWS access keys.

This project is designed to use:
✔ GitHub Actions OIDC
✔ AWS IAM Role with least privilege

## Required AWS Setup

1. Create IAM OIDC Provider
   - URL: https://token.actions.githubusercontent.com
   - Audience: sts.amazonaws.com

2. Create IAM Role
   - Trusted entity: Web identity
   - Provider: GitHub OIDC
   - Condition:
     repo:<YOUR_GITHUB_USERNAME>/<REPO_NAME>:ref:refs/heads/main

3. Attach Policies (Minimum):
   - AmazonEC2ContainerRegistryPowerUser
   - AWSAppRunnerFullAccess
   - CloudWatchLogsFullAccess

## Why this matters (Interview-ready)
- No AWS secrets stored in GitHub
- Short-lived credentials
- AWS-recommended CI/CD security model

## GitHub Workflow Usage
Use aws-actions/configure-aws-credentials with role-to-assume.
