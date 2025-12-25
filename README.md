# AI-Driven DevOps Incident Management on AWS

### Evaluating AWS DevOps Agent (Preview) Using Real Operational Signals

## Overview

This repository implements a **controlled, production-style incident simulation environment** to **evaluate AWS DevOps Agent (Preview)** using **real AWS infrastructure, real CI/CD deployments, and real failure scenarios**.

The project intentionally generates **observable operational signals**—deployments, configuration changes, runtime failures, rollbacks, and teardown—so AWS DevOps Agent can:

* Discover workload topology
* Correlate CI/CD activity with incidents
* Investigate failures using real CloudWatch telemetry

> **Important**
>
> This project is designed for **observation and investigation only**.
> AWS DevOps Agent does **not** perform autonomous remediation, trigger pipelines, or modify infrastructure in this repository.

---

## Project Objective

The primary objective of this project is to **understand and validate how AWS DevOps Agent behaves** when exposed to realistic DevOps and SRE workflows.

This repository is **not** focused on building a feature-rich application. Instead, it focuses on:

* Deterministic infrastructure changes
* Intentional failure injection
* Explicit rollback paths
* Secure CI/CD authentication
* Clean, auditable infrastructure topology

This makes the project suitable for:

* DevOps Agent evaluation
* Platform engineering reviews
* Senior DevOps / SRE interviews

---

## High-Level Architecture

```
Developer
   |
   | (GitHub Actions)
   v
GitHub CI/CD (OIDC)
   |
   | terraform init / plan / apply / destroy
   v
AWS Account
   |
   +-- API Gateway
   |      |
   |      v
   |   Lambda Function
   |      |
   |      v
   |  CloudWatch Logs & Metrics
   |
   +-- IAM Roles (OIDC + Lambda Execution)
   
AWS DevOps Agent (Preview)
   |
   | Observes topology, logs, metrics, deploy history
   v
Incident Investigation & Correlation
```

AWS DevOps Agent is configured **outside this repository** and attaches to the AWS account to ingest telemetry and deployment context.

---

## Infrastructure Model

### Terraform Layout

This repository uses **two distinct Terraform scopes**:

### 1️⃣ Bootstrap (One-Time, Manual)

Path:

```
terraform/bootstrap/
```

Purpose:

* Create **Terraform remote backend infrastructure**
* Create **GitHub OIDC trust and IAM roles**

Characteristics:

* Executed **manually**
* Run once per AWS account
* **Never destroyed by CI/CD**

Files include:

* `backend-infra.tf`
* `github-oidc.tf`
* `provider.tf`
* `outputs.tf`

---

### 2️⃣ Application Infrastructure (CI/CD-Driven)

Path:

```
terraform/lambda/
```

Purpose:

* Deploy and manage the actual application stack

Managed via GitHub Actions:

* API Gateway
* Lambda function
* IAM execution roles
* Logging permissions
* Environment variables (`FAIL_MODE`)

Files include:

* `backend.tf`
* `provider.tf`
* `apigateway.tf`
* `function_lambda.tf`
* `iam.tf`
* `outputs.tf`

All **application infrastructure changes** are applied **only via CI/CD**.

---

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       ├── deploy-lambda.yml
│       ├── inject-failure.yml
│       ├── rollback-lambda.yml
│       └── destroy.yml
│
├── app/
│   └── lambda_handler.py
│
└── terraform/
    ├── bootstrap/
    │   ├── backend-infra.tf
    │   ├── github-oidc.tf
    │   ├── provider.tf
    │   └── outputs.tf
    │
    └── lambda/
        ├── backend.tf
        ├── provider.tf
        ├── apigateway.tf
        ├── function_lambda.tf
        ├── iam.tf
        └── outputs.tf
```

---

## Lambda Failure Injection Model

The Lambda function (`app/lambda_handler.py`) is intentionally minimal and deterministic.

### Behavior

* Reads environment variable `FAIL_MODE`
* If `FAIL_MODE=true`:

  * Raises an exception
  * Produces CloudWatch error logs
* Otherwise:

  * Returns a healthy JSON response

There are **no synthetic latency, throttling, or random failure modes**.

This ensures:

* Clear causality
* Clean incident timelines
* Easy investigation by AWS DevOps Agent

---

## CI/CD Workflows

All application-level infrastructure changes are driven by GitHub Actions.

### Workflow Summary

| Workflow              | Purpose                                |
| --------------------- | -------------------------------------- |
| `deploy-lambda.yml`   | Deploy or update the application stack |
| `inject-failure.yml`  | Set `FAIL_MODE=true` to induce failure |
| `rollback-lambda.yml` | Restore Lambda to healthy state        |
| `destroy.yml`         | Destroy application infrastructure     |

All workflows:

* Authenticate to AWS using **OIDC**
* Run Terraform against the same remote backend
* Produce auditable deployment history

---

### Deploy Workflow

* Initializes Terraform in `terraform/lambda`
* Applies API Gateway, Lambda, IAM resources
* Leaves Lambda in healthy state

**Outcome:**
A reachable API endpoint with baseline telemetry.

---

### Inject Failure Workflow

* Updates Lambda environment (`FAIL_MODE=true`)
* Applies change via Terraform

**Outcome:**

* Lambda errors
* CloudWatch error metrics
* Clear incident start time

---

### Rollback Workflow

* Resets `FAIL_MODE`
* Applies configuration via Terraform

**Outcome:**

* Service recovery
* Clean incident resolution signal

---

### Destroy Workflow

* Runs `terraform destroy` on application stack
* Preserves Terraform backend and OIDC setup

Used for:

* Cost control
* Clean test cycles

---

## What AWS DevOps Agent Does and Does Not Do

### ✅ What AWS DevOps Agent **Does**

In this project, AWS DevOps Agent is used to:

* Observe CloudWatch logs, metrics, and alarms
* Discover infrastructure topology
* Correlate CI/CD deployments with incidents
* Assist in incident investigation and root-cause analysis

---

### ❌ What AWS DevOps Agent **Does NOT** Do

AWS DevOps Agent in this setup:

* Does **not** perform autonomous remediation
* Does **not** trigger GitHub Actions workflows
* Does **not** apply Terraform changes
* Does **not** perform Terraform drift detection
  (Terraform already handles drift independently)

All changes remain **explicitly human- or pipeline-driven**.

---

## Implemented vs Exploratory Scope

### Implemented in This Repo

* Terraform-managed API Gateway + Lambda
* Secure GitHub Actions → AWS authentication (OIDC)
* Deterministic failure injection
* Explicit rollback workflows
* Real CloudWatch telemetry

---

### Exploratory / External

* AWS DevOps Agent onboarding and configuration
* Investigation review in AWS console
* Integration with ticketing or collaboration tools

These are intentionally **outside the repository**.

---

## End-to-End Usage

1. Run Terraform in `terraform/bootstrap` (one time)
2. Push repository to GitHub
3. Run **deploy-lambda**
4. Validate API endpoint
5. Run **inject-failure**
6. Observe errors in CloudWatch
7. Investigate using AWS DevOps Agent
8. Run **rollback-lambda**
9. (Optional) Run **destroy**

---

## Final Notes

This repository is **not a demo** and **not a tutorial**.

It is a **controlled operational sandbox** designed to:

* Produce real incidents
* Validate investigation tooling
* Evaluate AWS DevOps Agent against real systems

---

### 👤 Author

**Digambar Rajaram**
Infrastructure & DevOps Engineer

GitHub: [https://github.com/digambarrajaram](https://github.com/digambarrajaram)
