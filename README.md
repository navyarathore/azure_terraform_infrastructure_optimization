# Azure Terraform Infrastructure - NGINX Deployment

![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![NGINX](https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=nginx&logoColor=white)

A modular, scalable Terraform infrastructure on Azure for deploying a Dockerized NGINX web application with HTTPS, load balancing, and Jenkins CI/CD automation.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Deployment](#detailed-deployment)
- [Environment Configuration](#environment-configuration)
- [Jenkins CI/CD](#jenkins-cicd)
- [Module Documentation](#module-documentation)
- [Contributing](#contributing)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Cost Optimization](#cost-optimization)

---

## Overview

This project provides a complete Infrastructure as Code (IaC) solution for deploying a secure, scalable web application on Azure using Terraform.

### What's Included

- **Complete Infrastructure**: Production-ready Azure infrastructure with VMs, networking, load balancing, and container registry
- **Multi-Environment**: Separate configurations for dev (2 VMs), test (3 VMs), and production (5 VMs)
- **Security First**: HTTPS end-to-end encryption, private VM deployment, NSGs, and bastion host access
- **High Availability**: Multiple VMs deployed in Availability Sets
- **Jenkins Automation**: Complete CI/CD pipeline for automated deployment
- **Cost Optimized**: Comprehensive tagging and right-sized resources

---

## Architecture

### Infrastructure Components

The infrastructure consists of the following Azure resources deployed across multiple resource groups:

#### Network Architecture
- **Virtual Network**: Segmented into public and private subnets (10.x.0.0/16)
  - **Public Subnet** (10.x.1.0/24): Hosts Application Gateway and Bastion Host
  - **Private Subnet** (10.x.2.0/24): Hosts application VMs (no public IPs)
- **NAT Gateway**: Provides controlled outbound internet access for private VMs
- **Network Security Groups (NSGs)**: Enforce restrictive firewall rules
  - Public NSG: Allows ports 80, 443, 22 (bastion), and 65200-65535 (App Gateway management)
  - Private NSG: Allows traffic only from public subnet

#### Compute Resources
- **VM Availability Set**: Ensures high availability across fault and update domains
  - Dev: 2 VMs | Test: 3 VMs | Prod: 5 VMs
  - OS: Ubuntu 22.04 LTS
  - Docker pre-installed via cloud-init
  - NGINX containers pulled from Azure Container Registry

#### Load Balancing & Security
- **Application Gateway**: Layer 7 load balancer with SSL termination
  - Standard_v2 SKU (dev/test) or WAF_v2 (production)
  - HTTP to HTTPS redirection
  - Health probes: `/health` endpoint (30s intervals)
  - Cookie-based session affinity

#### Container Registry
- **Azure Container Registry (ACR)**: Private Docker registry
  - Standard tier for all environments
  - Admin access enabled for VM authentication
  - Repository: nginx-https

#### Access & Management
- **Bastion Host**: Secure jump server for SSH access to private VMs
  - Standard_B1s VM in public subnet
  - SSH key authentication only
  - Configurable allowed CIDR ranges

#### State Management
- **Terraform Backend**: Azure Storage Account for remote state
  - Storage Account: tfstateazuresa
  - Container: tfstate
  - Enables team collaboration and state locking

### Security Architecture

The infrastructure implements defense-in-depth security with multiple layers:

#### Layer 1: Network Isolation
- **Private Subnet Deployment**: Application VMs have no public IPs
- **Public Subnet Segregation**: Only Application Gateway and Bastion in public subnet
- **NAT Gateway**: Controlled outbound internet access for private VMs

#### Layer 2: Network Security Groups
- **Public NSG**: Restricts ingress to ports 80, 443, 22 (bastion), and App Gateway management ports
- **Private NSG**: Allows traffic only from public subnet (Application Gateway and Bastion)
- **Default Deny**: All other inbound traffic is denied

#### Layer 3: Application Security
- **SSL/TLS Termination**: End-to-end HTTPS encryption
- **HTTP to HTTPS Redirect**: Automatic redirection enforces secure connections
- **Web Application Firewall**: Optional WAF_v2 for production environments
- **DDoS Protection**: Built-in Azure DDoS protection

#### Layer 4: VM Security
- **SSH Key Authentication**: Bastion host uses key-based authentication only
- **Password Authentication Disabled**: No password-based SSH access
- **OS Security**: Ubuntu 22.04 LTS with automatic security updates
- **Container Security**: Docker best practices and minimal base images

#### Layer 5: Data Protection
- **HTTPS End-to-End**: Encrypted traffic from client to backend
- **Self-Signed SSL Certificates**: Included (replaceable with custom certificates)
- **Storage Encryption**: Azure storage encryption at rest for Terraform state

### Terraform Module Structure

The infrastructure is organized into reusable Terraform modules:

- **Root Configuration** (`env/dev|test|prod/`)
  - `backend.tf`: Remote state configuration
  - `locals.tf`: Environment-specific variables
  - `main.tf`: Module instantiations
  - `variables.tf`: Variable definitions
  - `terraform.tfvars`: Configuration values
  - `outputs.tf`: Output values

- **Networking Module** (`modules/networking/`)
  - VNet, subnets, NAT Gateway, NSGs

- **Bastion Module** (`modules/bastion/`)
  - Bastion VM, public IP, SSH configuration

- **App Gateway Module** (`modules/app-gateway/`)
  - Application Gateway, SSL certificate, listeners, routing rules

- **Compute Module** (`modules/compute/`)
  - Availability Set, VMs, cloud-init, NICs

- **ACR Module** (`modules/acr/`)
  - Container Registry configuration

### Deployment Timeline

Typical deployment takes 25-35 minutes:

1. **Backend Bootstrap** (1-2 min): Create Azure Storage for Terraform state
2. **Terraform Init** (1-2 min): Download providers and initialize backend
3. **Networking** (2-3 min): Create VNet, subnets, NAT Gateway, NSGs
4. **ACR** (1-2 min): Create Azure Container Registry
5. **Application Gateway** (15-20 min): Deploy Application Gateway (longest step)
6. **Compute** (5-7 min): Deploy VMs in Availability Set
7. **Docker Build & Push** (2-3 min): Build NGINX image and push to ACR
8. **Cloud-init** (2-3 min): VMs pull and start Docker containers

---

## Features

### Infrastructure
- **Modular Architecture**: Reusable Terraform modules using official Azure provider
- **Multi-Environment Support**: Separate dev, test, and production configurations
- **High Availability**: VM Availability Sets with fault and update domain distribution
- **Layer 7 Load Balancing**: Application Gateway with health monitoring
- **Private Network Deployment**: VMs isolated in private subnet without public IPs
- **Scalable Design**: Fixed VM count per environment (2 dev, 3 test, 5 prod)

### Security
- **End-to-End Encryption**: HTTPS from client to backend with SSL/TLS termination
- **Network Isolation**: Private subnet deployment with NAT Gateway for outbound traffic
- **Secure Access**: Bastion host with SSH key authentication for VM management
- **Restrictive Firewall**: Network Security Groups with deny-by-default policies
- **Automatic HTTPS**: HTTP to HTTPS redirection enforced at Application Gateway
- **Flexible Certificates**: Self-signed SSL included, supports custom certificates

### Automation & DevOps
- **CI/CD Pipeline**: Jenkins integration for automated deployments
- **Infrastructure as Code**: Version-controlled Terraform configurations
- **Remote State Management**: Azure Storage backend with state locking
- **Automated Provisioning**: Cloud-init scripts for Docker and NGINX deployment
- **Build Scripts**: Automated Docker image building and ACR push
- **Multi-Environment**: Environment-specific configurations and variable files

---

## Project Structure

```
azure_terraform_infrastructure_optimization/
├── docker/
│   └── nginx/                 # NGINX Docker configuration
│       ├── Dockerfile
│       ├── nginx.conf
│       ├── default.conf
│       └── index.html
├── env/
│   ├── dev/                   # Development (2 VMs)
│   ├── test/                  # Test (3 VMs)
│   └── prod/                  # Production (3 VMs)
│       ├── backend.tf         # Remote state config
│       ├── variables.tf       # Variable definitions
│       ├── terraform.tfvars   # Variable values (EDIT THIS!)
│       ├── locals.tf          # Computed values
│       ├── main.tf            # Module instantiation
│       └── outputs.tf         # Output values
├── modules/
│   ├── networking/            # VNet, subnets, NSGs, NAT Gateway
│   ├── bastion/               # Bastion host (jump server)
│   ├── compute/               # Virtual Machines with Availability Set
│   ├── app-gateway/           # Application Gateway with HTTPS
│   └── acr/                   # Azure Container Registry
├── scripts/
│   ├── bootstrap-backend.sh   # Create Terraform backend
│   └── build-and-push-docker.sh # Build and push Docker image
├── Jenkinsfile                # Jenkins CI/CD pipeline
└── README.md                  # This file
```

---

## Prerequisites

### Required Tools

1. **Azure CLI** (2.50+)
   ```bash
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

2. **Terraform** (1.5+)
   ```bash
   wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
   unzip terraform_1.5.7_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

3. **Docker** (for building images)
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   ```

### Azure Requirements

- Active Azure subscription
- Permissions to create resources
- Service Principal for CI/CD (optional)

### Create Azure Service Principal

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"

az ad sp create-for-rbac \
  --name "terraform-sp" \
  --role="Contributor" \
  --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"
```

Save the output - you'll need it for Jenkins.

---

## Quick Start

Get up and running in 10 minutes!

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/azure_terraform_infrastructure_optimization.git
cd azure_terraform_infrastructure_optimization
chmod +x scripts/*.sh
```

### 2. Verify Prerequisites

```bash
# Check Azure CLI
az --version

# Check Terraform
terraform version

# Login to Azure
az login
az account show
```

### 3. Bootstrap Backend

```bash
./scripts/bootstrap-backend.sh
```

**Purpose**: Creates Azure Storage Account (`tfstateazuresa`) for Terraform state management.

### 4. Configure Environment

```bash
cd env/dev
nano terraform.tfvars
```

**All configuration is in `terraform.tfvars`**:
```hcl
# Security
admin_password = "YourSecurePassword123!"

# Bastion Host SSH Access 🆕
ssh_public_key   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."  # Your SSH public key
allowed_ssh_cidr = "*"  # Restrict to your IP: "203.0.113.1/32"

# Project settings (customize as needed)
project_name = "webapp"
location     = "eastasia"

# Infrastructure settings (pre-configured, modify if needed)
vm_sku         = "Standard_B2s"
instance_count = 2
# ... and more
```

**Password Requirements** (for VMs):
- 12-72 characters
- Must include uppercase, lowercase, number, and special character

**SSH Public Key** (for Bastion):
- Generate key: `ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_key`
- Copy public key: `cat ~/.ssh/azure_key.pub`
- Paste into `ssh_public_key` variable

### 5. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

**Note**: Deployment takes approximately 5-10 minutes for completion

### 6. Build Docker Image

```bash
./scripts/build-and-push-docker.sh dev
```

This builds the NGINX container and pushes it to Azure Container Registry.

### 7. Access Application

```bash
cd env/dev
APP_IP=$(terraform output -raw app_gateway_public_ip)
echo "https://$APP_IP"
```

Visit the URL in your browser (accept self-signed certificate warning).

---

## Detailed Deployment

### Step 1: Azure Login

```bash
az login
az account show
```

Verify you're in the correct subscription.

### Step 2: Initialize Backend

```bash
./scripts/bootstrap-backend.sh
```

This creates:
- Resource Group: `tfstate-rg`
- Storage Account: `tfstateazuresa`
- Container: `tfstate`

### Step 3: Configure Environment

```bash
cd env/dev
nano terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
admin_password = "YourSecurePassword123!"
```

**Password Requirements**:
- Minimum 12 characters, maximum 72
- Must contain uppercase letter
- Must contain lowercase letter
- Must contain number
- Must contain special character

### Step 4: Deploy Infrastructure

```bash
cd env/dev
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### Step 5: Build Docker Image

```bash
./scripts/build-and-push-docker.sh dev latest
```

This will:
1. Build the NGINX Docker image
2. Tag it with `latest` and environment
3. Push to Azure Container Registry
4. Display the image URL

### Step 6: Verify Deployment

```bash
cd env/dev
terraform output
```

Test the application:
```bash
APP_IP=$(terraform output -raw app_gateway_public_ip)

# Test HTTP (redirects to HTTPS)
curl -I http://$APP_IP

# Test HTTPS
curl -k https://$APP_IP

# Test health endpoint
curl -k https://$APP_IP/health
```

### Step 7: Monitor VMs

```bash
# Get resource group
RG_NAME=$(terraform output -json resource_group_names | jq -r '.compute')

# List VMs
az vm list --resource-group $RG_NAME --output table

# Check VM status
az vm get-instance-view \
  --resource-group $RG_NAME \
  --name dev-multicloud-vm-0 \
  --query "instanceView.statuses[1]" \
  --output table
```

---

## Environment Configuration

### Dev Environment
- **Location**: East Asia
- **VM SKU**: Standard_B2s
- **VM Count**: 2
- **ACR**: Standard tier
- **Purpose**: Development and testing

### Test Environment
- **Location**: East Asia
- **VM SKU**: Standard_B2ms
- **VM Count**: 3
- **ACR**: Standard tier
- **Purpose**: Pre-production validation

### Production Environment
- **Location**: East Asia
- **VM SKU**: Standard_B2s
- **VM Count**: 3
- **ACR**: Standard tier
- **App Gateway**: Standard_v2
- **Purpose**: Production workloads

Each environment has independent:
- Terraform state files
- Resource groups
- Network CIDR ranges
- VM sizing and count
- Tag values

---

## Jenkins CI/CD

### Pipeline Overview

The Jenkinsfile provides automated deployment with:
- Environment selection (dev/test/prod)
- Action choice (plan/apply/destroy)
- Optional Docker image build
- Approval gates for apply/destroy actions
- VM restart after image update

### Setup Jenkins

#### 1. Install Plugins

- Azure CLI Plugin
- Pipeline Plugin
- Docker Pipeline Plugin
- Git Plugin

#### 2. Configure Credentials

Add Azure Service Principal as Jenkins credentials:
- ID: `azure-sp`
- Type: Secret text or Username with password
- Values from `az ad sp create-for-rbac` output

#### 3. Create Pipeline Job

1. New Item → Pipeline
2. Configure:
   - **Pipeline from SCM**: Git
   - **Repository URL**: Your GitHub repo URL
   - **Script Path**: `Jenkinsfile`
3. Save

#### 4. Run Pipeline

1. Click "Build with Parameters"
2. Select:
   - **ENVIRONMENT**: `dev`, `test`, or `prod`
   - **ACTION**: `plan`, `apply`, or `destroy`
   - **BUILD_DOCKER**: Check to build Docker image
3. Click "Build"
4. Approve when prompted (for apply/destroy)

### Pipeline Stages

1. **Checkout**: Clone repository
2. **Setup Terraform**: Install Terraform binary
3. **Azure Login**: Authenticate using service principal
4. **Terraform Init**: Initialize backend and providers
5. **Terraform Validate**: Validate configuration syntax
6. **Terraform Plan**: Generate execution plan
7. **Approval** (for apply): Manual approval gate
8. **Terraform Apply**: Deploy infrastructure
9. **Build Docker** (optional): Build and push NGINX image
10. **Restart VMs** (optional): Restart VMs to pull new image
11. **Terraform Destroy** (for destroy): Remove infrastructure

### Environment Variables

Set these in Jenkins credentials or pipeline:

```groovy
environment {
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_CLIENT_SECRET   = credentials('azure-client-secret')
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
    ARM_TENANT_ID       = credentials('azure-tenant-id')
}
```

---

## Module Documentation

### Networking Module

Creates the network foundation for all environments.

**Path**: `modules/networking/`

**Resources**:
- Virtual Network
- Public subnet (for Application Gateway)
- Private subnet (for VMs)
- NAT Gateway with Public IP
- Application Gateway Public IP
- Network Security Groups (NSGs)

**Key Variables**:
```hcl
vnet_address_space   = "10.0.0.0/16"
public_subnet_cidr   = "10.0.1.0/24"
private_subnet_cidr  = "10.0.2.0/24"
```

**Outputs**:
- `vnet_id` - Virtual Network ID
- `public_subnet_id` - Public subnet ID
- `private_subnet_id` - Private subnet ID
- `app_gateway_public_ip_id` - App Gateway public IP ID

### Compute Module

Deploys Virtual Machines in Availability Set.

**Path**: `modules/compute/`

**Resources**:
- Availability Set
- Network Interfaces (one per VM)
- Linux Virtual Machines (Ubuntu 20.04)
- Cloud-init configuration
- Backend pool associations

**Key Variables**:
```hcl
vm_sku         = "Standard_B2s"
instance_count = 2
admin_username = "azureuser"
admin_password = "YourSecurePassword123!"
```

**Features**:
- Fixed VM count (no auto-scaling)
- Docker pre-installed via cloud-init
- Automatic container deployment from ACR
- Health probe integration

**Outputs**:
- `vm_ids` - List of VM IDs
- `vm_names` - List of VM names
- `vm_private_ips` - List of private IP addresses
- `availability_set_id` - Availability Set ID

### Application Gateway Module

Provides HTTPS load balancing with optional WAF.

**Path**: `modules/app-gateway/`

**Resources**:
- Application Gateway (Standard_v2 or WAF_v2)
- SSL certificate (self-signed)
- Backend pools
- HTTP listener (redirects to HTTPS)
- HTTPS listener
- Routing rules
- Health probes (HTTP and HTTPS)

**Key Variables**:
```hcl
sku_name     = "Standard_v2"  # or WAF_v2
sku_tier     = "Standard_v2"  # or WAF_v2
capacity     = 2
enable_http2 = true
```

**Features**:
- End-to-end HTTPS encryption
- HTTP to HTTPS automatic redirection
- Backend health monitoring
- Cookie-based session affinity
- Optional Web Application Firewall (WAF) for production

**Outputs**:
- `app_gateway_id` - Application Gateway ID
- `app_gateway_public_ip` - Public IP address
- `backend_address_pool_id` - Backend pool ID

### ACR Module

Container image storage and management.

**Path**: `modules/acr/`

**Resources**:
- Azure Container Registry
- Admin access credentials
- Network rules
- Optional geo-replication (Premium tier)

**Key Variables**:
```hcl
sku                = "Standard"  # Basic, Standard, or Premium
admin_enabled      = true
georeplication_locations = []  # For Premium tier
```

**Tiers**:
- **Basic**: Development and testing
- **Standard**: General purpose, sufficient for most workloads
- **Premium**: Production with geo-replication and advanced features

**Outputs**:
- `acr_id` - Container Registry ID
- `acr_name` - Container Registry name
- `acr_login_server` - Login server URL
- `acr_admin_username` - Admin username
- `acr_admin_password` - Admin password (sensitive)

---

## Acknowledgments

- [Azure Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [HashiCorp Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)
- Community contributors and testers


---

*Last Updated: 7 October 2025*  
