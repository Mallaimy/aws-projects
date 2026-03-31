# AWS E-Commerce Platform Infrastructure

3-tier cloud-native infrastructure built with Terraform for AWS ECS, demonstrating enterprise-grade architecture patterns required for Cloud Engineer/DevOps roles.

# 🚀 AWS E-Commerce Infrastructure (Terraform + ECS Fargate)

## 🏗️ Architecture Overview

This project demonstrates a production-grade cloud architecture deployed on AWS using Terraform.

It follows a secure and scalable 3-tier design:

**Internet → Application Load Balancer → ECS Fargate → RDS PostgreSQL**

---

## 📐 Architecture Diagram

<p align="center">
  <img src="/images/arc.png" width="700"/>
</p>

---

## ⚙️ Tech Stack

- **Infrastructure as Code**: Terraform
- **Compute**: AWS ECS Fargate
- **Load Balancing**: Application Load Balancer (ALB)
- **Database**: RDS PostgreSQL
- **Networking**: VPC, Subnets, NAT Gateway
- **Security**: IAM, Security Groups, Secrets Manager
- **Monitoring**: CloudWatch Logs

---

## 🔐 Key Design Decisions

- ECS tasks run in **private subnets** for security
- RDS is **not publicly accessible**
- ALB is the **only public entry point**
- Secrets are managed via **AWS Secrets Manager**
- Multi-AZ deployment for **high availability**

---

## 📊 Architecture Highlights

- Highly available across multiple Availability Zones
- Fully isolated network design (public/private separation)
- Scalable container-based application layer
- Secure database connectivity with least privilege access

---

## 🚀 Deployment

```bash
terraform init
terraform plan
terraform apply