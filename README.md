# AWS E-Commerce Platform Infrastructure

3-tier cloud-native infrastructure built with Terraform for AWS ECS, demonstrating enterprise-grade architecture patterns required for Cloud Engineer/DevOps roles.

## Architecture Overview
![Architecture Diagram](/images/arc.png)

## Infrastructure as Code

### Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- AWS account with appropriate limits

### Deployment

```bash
cd terraform/
terraform init
terraform plan
terraform apply

### Verifications

Copy (Bash)

# Test ALB endpoint
curl http://$(terraform output -raw alb_dns_name)/health

# Check ECS tasks
aws ecs list-tasks --cluster ecs-cluster

# Verify RDS
aws rds describe-db-instances --db-instance-identifier ecommerce-db




Key Design Decisions
1. High Availability
2 Availability Zones for all tiers
Multi-AZ ready database configuration
Auto-healing ECS service (desired count: 2)
2. Security
Private subnets for application and database
Security group references (not CIDR blocks) for internal traffic
Secrets Manager for database credentials (no hardcoded passwords)
IAM roles with least privilege
3. Scalability
Fargate serverless compute (no EC2 management)
ALB with target group auto-registration
Database storage can scale up to 64TB
Project Structure
plain
Copy
terraform/
├── vpc.tf              # Network foundation (Day 1-3)
├── security-groups.tf  # Firewall rules (Day 2)
├── ecs.tf              # Container orchestration (Day 4)
├── rds.tf              # Database layer (Day 5)
└── README.md           # This file
Cost Optimization
Table
Resource	Monthly Cost	Strategy
ECS Fargate	~$8	2 tasks x 0.25 vCPU
ALB	~$16	Minimum for 2 AZs
RDS t3.micro	~$13	Free tier eligible
NAT Gateway	~$32	Required for private subnet internet
Total	~$70/month	Development environment
Next Steps
[1] Replace Nginx with Node.js API application
[2] Add CI/CD pipeline (GitHub Actions → ECR → ECS)
[3] Implement auto-scaling policies
[4] Add CloudWatch alarms for monitoring
[5] Enable SSL/TLS with ACM certificate



Built as portfolio project demonstrating AWS architecture skills for Cloud Engineer positions.
Terraform
AWS ECS, RDS, ALB, VPC
Infrastructure as Code
DevOps best practices