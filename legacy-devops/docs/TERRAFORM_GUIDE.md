# Terraform Quick Start Guide

## What is Terraform?

Terraform is Infrastructure as Code (IaC) - manage AWS resources using code files instead of clicking in console.

## Files

- `main.tf` - AWS resource definitions
- `variables.tf` - Input variables
- `terraform.tfvars.example` - Example configuration

## Prerequisites

```bash
# Install Terraform
brew install terraform  # macOS
# or download from https://www.terraform.io/downloads.html

# Verify installation
terraform --version

# Install AWS CLI
brew install awscli

# Configure AWS credentials
aws configure
# Enter: Access Key, Secret Key, Region, Output format
```

## Quick Start

```bash
cd terraform

# 1. Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# 2. Edit configuration
nano terraform.tfvars
# Update: region, environment, CIDR blocks, instance type

# 3. Initialize Terraform
terraform init
# Downloads AWS provider plugin

# 4. Plan infrastructure
terraform plan
# Shows what will be created

# 5. Apply changes
terraform apply
# Creates infrastructure in AWS
# Type 'yes' to confirm

# 6. View outputs
terraform output
# Shows ALB DNS name and subnet IDs
```

## Resources Created

### VPC & Networking
- **VPC**: Virtual Private Cloud
- **Public Subnets**: 2 (10.0.1.0/24, 10.0.2.0/24)
- **Private Subnets**: 2 (10.0.3.0/24, 10.0.4.0/24)
- **Internet Gateway**: For public internet access
- **Route Tables**: Public routes configured

### Security & Load Balancing
- **Security Group**: For ALB (ports 80, 443)
- **Application Load Balancer**: Distributes traffic
- **Target Group**: Routes traffic to instances
- **ALB Listener**: Port 80 → Target Group

## Common Commands

```bash
# Format code
terraform fmt

# Validate syntax
terraform validate

# Check what will change
terraform plan

# Apply changes
terraform apply

# Apply specific resource
terraform apply -target=aws_vpc.main

# View resource details
terraform show

# Output specific value
terraform output alb_dns_name

# Destroy infrastructure
terraform destroy
# Type 'yes' to confirm

# Destroy specific resource
terraform destroy -target=aws_security_group.alb
```

## Terraform State

### Local State
```bash
# State stored in terraform.tfstate
# Contains all resource information
# IMPORTANT: Don't commit to git!
```

### Remote State (Recommended for Production)

```hcl
# In main.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "devops/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

Setup S3 backend:
```bash
# Create S3 bucket
aws s3 mb s3://my-terraform-state --region us-east-1

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1

# Initialize backend
terraform init
```

## Modifying Configuration

### Change Environment
```bash
# Edit terraform.tfvars
terraform apply
# Terraform updates only changed resources
```

### Add New Variable
```hcl
# In variables.tf
variable "new_var" {
  description = "Description"
  type        = string
  default     = "value"
}

# In terraform.tfvars
new_var = "custom_value"

# Apply
terraform apply
```

### Update Resource
```hcl
# Edit resource in main.tf
resource "aws_lb" "main" {
  name = "new-name"  # Change this
  ...
}

# Apply
terraform apply
# Shows what will change before confirming
```

## Useful Outputs

```bash
# Get ALB DNS name
terraform output alb_dns_name
# Use this to access your application

# Get VPC ID
terraform output vpc_id

# Get subnet IDs
terraform output public_subnet_ids
terraform output private_subnet_ids
```

## Variables & Environments

### Development
```hcl
# terraform.tfvars
aws_region  = "us-east-1"
environment = "dev"
instance_type = "t3.micro"  # Cheaper
```

### Production
```hcl
# terraform.prod.tfvars
aws_region  = "us-east-1"
environment = "prod"
instance_type = "t3.medium"  # More resources
```

Apply specific environment:
```bash
terraform apply -var-file=terraform.prod.tfvars
```

## Scaling

### Add More Instances

Edit `terraform.tfvars`:
```hcl
# Modify target group to add more instances
```

Or update in code directly, then:
```bash
terraform plan
terraform apply
```

## Monitoring & Debugging

```bash
# Enable debug logging
TF_LOG=DEBUG terraform apply

# Save plan to file
terraform plan -out=plan.tfplan

# Apply saved plan
terraform apply plan.tfplan

# Describe specific resource
terraform state show aws_vpc.main

# List all resources
terraform state list
```

## Best Practices

1. **Always use `terraform plan` first**
   ```bash
   terraform plan  # Review before applying
   ```

2. **Version control** (but exclude state file)
   ```bash
   echo "*.tfstate*" >> .gitignore
   git add *.tf
   git commit -m "Infrastructure update"
   ```

3. **Use meaningful variable names**
   ```hcl
   variable "app_environment" {  # Clear name
     default = "production"
   }
   ```

4. **Document resources with comments**
   ```hcl
   # Application Load Balancer for traffic distribution
   resource "aws_lb" "main" { ... }
   ```

5. **Use modules for reusability**
   ```hcl
   module "app_servers" {
     source = "./modules/app-servers"
     environment = var.environment
   }
   ```

## Troubleshooting

### Error: Invalid AWS credentials
```bash
# Reconfigure AWS
aws configure

# Verify credentials
aws sts get-caller-identity
```

### Error: Resource already exists
```bash
# Import existing resource
terraform import aws_vpc.main vpc-12345678

# Or destroy and recreate
terraform destroy
terraform apply
```

### Terraform locked
```bash
# Remove lock file
rm .terraform.lock.hcl

# Or force unlock (if using remote state)
terraform force-unlock <LOCK_ID>
```

## Cleanup

```bash
# Destroy all infrastructure
terraform destroy

# Destroy specific resource
terraform destroy -target=aws_lb.main

# Verify destruction
aws ec2 describe-vpcs --region us-east-1
```

## Next Steps

1. ✅ Create basic infrastructure
2. Add auto-scaling groups
3. Add database (RDS)
4. Add caching (ElastiCache)
5. Setup CDN (CloudFront)
6. Configure DNS (Route53)
7. Setup monitoring (CloudWatch)

## Resources

- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices.html)
- [AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Registry](https://registry.terraform.io/)

