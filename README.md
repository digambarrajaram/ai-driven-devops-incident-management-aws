# AI-Driven DevOps Incident Management on AWS

This project demonstrates a **real-world DevOps and AIOps implementation** using **AWS DevOps Agent (Preview)** to autonomously investigate application and infrastructure incidents.

The platform provisions infrastructure using **Terraform**, deploys a containerized **web application** using **GitHub Actions CI/CD**, and enables **AI-driven root cause analysis and remediation recommendations** using AWS-native observability signals.

---

## 🚀 Project Overview

Modern DevOps teams spend significant time investigating production issues by analyzing metrics, logs, and deployment history.

This project simulates an enterprise-grade workflow where:

- A real web application is deployed on AWS
- CI/CD pipelines trigger deployments automatically
- CloudWatch monitors application and infrastructure health
- AWS DevOps Agent autonomously investigates incidents
- Root cause analysis and remediation suggestions are generated

---

## 🏗 Architecture

Developer Commit  
→ GitHub Actions CI/CD  
→ Amazon ECR (Docker Image)  
→ AWS App Runner (Web Application)  
→ CloudWatch Metrics & Logs  
→ CloudWatch Alarms  
→ AWS DevOps Agent (Preview)  
→ Root Cause Analysis & Remediation  

---

## 🧰 Tech Stack

### Cloud & Infrastructure
- AWS App Runner
- Amazon ECR
- AWS IAM
- Amazon CloudWatch
- AWS DevOps Agent (Preview)

### DevOps & Automation
- Terraform (Infrastructure as Code)
- GitHub Actions (CI/CD)
- Docker

### Application
- Python (Flask)
- Containerized Web Application

---

## 📂 Repository Structure

```
autoops-ai/
│
├── app/
│   ├── app.py
│   └── Dockerfile
│
├── infra/
│   └── terraform/
│       ├── provider.tf
│       ├── ecr.tf
│       ├── iam.tf
│       ├── apprunner.tf
│       ├── cloudwatch.tf
│       └── outputs.tf
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
└── README.md
```

---

## ⚙️ Infrastructure Provisioning (Terraform)

All AWS infrastructure is provisioned using Terraform:

- Amazon ECR repository for Docker images
- AWS App Runner service for application runtime
- IAM roles with least-privilege access
- CloudWatch logging and metrics

### Deploy Infrastructure

```bash
cd infra/terraform
terraform init
terraform apply
```

---

## 🔄 CI/CD Pipeline (GitHub Actions)

The CI/CD pipeline automatically:

1. Builds the Docker image
2. Pushes the image to Amazon ECR
3. Triggers App Runner auto-deployment

Pipeline runs on every push to the `main` branch.

---

## 🧪 Application Failure Scenarios

The web application includes intentional failure endpoints to simulate real incidents:

| Endpoint | Purpose |
|--------|--------|
| `/` | Health check |
| `/stress` | Simulates high CPU usage |
| `/error` | Simulates application error |

These scenarios generate real CloudWatch alarms for investigation.

---

## 🤖 AWS DevOps Agent Integration

AWS DevOps Agent (Preview) is configured to:

- Consume CloudWatch metrics and logs
- React to CloudWatch alarms
- Correlate infrastructure, application, and deployment signals
- Generate root cause analysis and remediation recommendations

> AWS DevOps Agent is currently in **Preview**. This project aligns with AWS-supported capabilities without overclaiming automation.

---

## 🧠 Key Learnings

- Infrastructure provisioning using Terraform
- CI/CD automation with GitHub Actions
- Container-based deployment using AWS App Runner
- AI-driven incident investigation using AWS DevOps Agent
- End-to-end observability and incident response workflows

---

## 📌 Resume-Ready Summary

Built a production-grade DevOps incident management platform using Terraform, GitHub Actions CI/CD, and AWS DevOps Agent (Preview) to autonomously investigate application and infrastructure incidents using CloudWatch metrics, logs, and deployment signals.

---

## ⚠️ Disclaimer

AWS DevOps Agent is used in **Preview mode**. Configurations follow AWS documentation and best practices available at the time of implementation.

---

## 📬 Author

Digambar Rajaram  
DevOps | Cloud | Automation
