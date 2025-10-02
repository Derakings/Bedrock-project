# Deployment & Architecture Guide

## Architecture Overview
This project provisions a secure, production-ready AWS infrastructure for the InnovateMart retail-store-sample-app using Terraform and Kubernetes on Amazon EKS. Key components:

- **VPC** with public/private subnets
- **Amazon EKS** cluster with managed node groups
- **IAM roles/policies** for cluster, nodes, and developer access
- **Managed AWS databases**: RDS MySQL (catalog), RDS PostgreSQL (orders), DynamoDB (carts)
- **Kubernetes manifests** for all microservices and dependencies
- **ALB Ingress** for UI service exposure
- **CI/CD pipeline** via GitHub Actions for automated provisioning and deployment

## Accessing the Running Application
Once deployed, the UI service is exposed via an AWS Application Load Balancer (ALB). Find the external address with:

```
kubectl get svc ui
```
or
```
kubectl get ingress ui-ingress
```
The output will show a DNS name (e.g., `xxxx.elb.amazonaws.com`). Open this in your browser to access the app.

## Developer IAM User & Kubeconfig Instructions

### IAM User Credentials
- Username: `innocent-dev`
- Password: Set manually in AWS Console (IAM > Users > innocent-dev > Security credentials > Manage Console access)
- Access Key/Secret: Managed via AWS Console or GitHub Secrets for CI/CD

### Kubeconfig Setup (Read-Only Access)
1. Ensure the IAM user has the correct EKS access policy (AmazonEKSAdminViewPolicy) for namespace `default`.
2. On the developer's machine, configure AWS CLI with the IAM user's credentials:
  ```
  aws configure
  # Enter access key, secret key, region
  ```
3. Update kubeconfig for EKS:
  ```
  aws eks update-kubeconfig --region us-east-1 --name innovatemart-cluster
  ```
4. The developer can now run read-only kubectl commands:
  ```
  kubectl get pods -n default
  kubectl describe pod <pod-name> -n default
  kubectl get svc -n default
  ```

## Notes
- All secrets and credentials are managed securely via AWS SSM and GitHub Secrets.
- No sensitive values are hardcoded in the codebase.
- For production, always use secure secret injection and least-privilege IAM policies.

# InnovateMart Retail Store Sample App

## Project Overview
This project provisions a secure, production-ready AWS infrastructure and CI/CD pipeline for the InnovateMart retail-store-sample-app. It uses Terraform for infrastructure as code, Kubernetes for application orchestration, and GitHub Actions for automated deployment.

### Key Components
- **VPC**: Custom AWS VPC with public and private subnets
- **Amazon EKS**: Managed Kubernetes cluster with node groups
- **IAM**: Roles and policies for cluster, nodes, and developer access
- **Managed Databases**: RDS MySQL (catalog), RDS PostgreSQL (orders), DynamoDB (carts)
- **Kubernetes Manifests**: Deploys all microservices and dependencies
- **ALB Ingress**: Exposes the UI service via AWS Application Load Balancer
- **CI/CD Pipeline**: GitHub Actions automates provisioning and deployment

## Architecture Diagram
```
AWS Cloud
│
├── VPC (Public & Private Subnets)
│   ├── EKS Cluster
│   │   ├── Node Groups
│   │   ├── Kubernetes Services & Deployments
│   │   └── ALB Ingress (UI)
│   ├── RDS MySQL (catalog)
│   ├── RDS PostgreSQL (orders)
│   └── DynamoDB (carts)
│
└── IAM Users/Roles
```

## Setup & Deployment

### Prerequisites
- AWS account with required permissions
- GitHub repository with secrets configured (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- Terraform and kubectl installed locally (for manual steps)

### Steps
1. **Clone the repository:**
  ```
  git clone <repo-url>
  cd Bedrock-project
  ```
2. **Configure AWS credentials:**
  - Locally: `aws configure`
  - In GitHub: Add secrets to repository settings
3. **Provision infrastructure:**
  - Locally: `terraform init && terraform apply`
  - CI/CD: Push to `main` branch to trigger GitHub Actions
4. **Deploy application:**
  - CI/CD pipeline will patch manifests and deploy to EKS
  - Manual: `kubectl apply -f kubernetes.yaml`

## Accessing the Application
After deployment, the UI service is exposed via an AWS ALB. Find the external address:
```
kubectl get svc ui
# or
kubectl get ingress ui-ingress
```
Open the DNS name in your browser to access the app.

## Developer IAM User & Kubeconfig

### IAM User Credentials
- Username: `innocent-dev`
- Password: Set/reset in AWS Console (IAM > Users > innocent-dev > Security credentials)
- Access Key/Secret: Managed via AWS Console or GitHub Secrets

### Kubeconfig Setup (Read-Only Access)
1. Configure AWS CLI with IAM user credentials:
  ```
  aws configure
  ```
2. Update kubeconfig:
  ```
  aws eks update-kubeconfig --region us-east-1 --name innovatemart-cluster
  ```
3. Run read-only kubectl commands:
  ```
  kubectl get pods -n default
  kubectl describe pod <pod-name> -n default
  kubectl get svc -n default
  ```

## Security & Best Practices
- All secrets and credentials are managed via AWS SSM Parameter Store and GitHub Secrets
- No hardcoded secrets in codebase or manifests
- IAM policies follow least-privilege principle
- Use secure secret injection for all sensitive values

## Troubleshooting
- **Pods CrashLoopBackOff:** Check logs with `kubectl logs <pod-name>` and verify secrets/configmaps
- **Terraform output missing:** Ensure output blocks exist and resources are created
- **EKS API unreachable:** Check cluster status, update kubeconfig, verify network/DNS

## Contact & Support
For questions or issues, open a GitHub issue or contact the project maintainer.
