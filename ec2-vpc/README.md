Terrafrom AWS VPC + EC2 infratructure

Overview
This project provisions a production-style AWS infrastructure using Terraform, including:
    Custom VPC
    Public & Private Subnets
    Internet Gateway & NAT Gateway
    Route Tables (Public & Private)
    Bastion Host (Public EC2)
    Private Backend EC2 Instances
    Security Groups
    Key Pair for SSH access

Architecture

    VPC (10.0.0.0/16)
    │
    ├── Public Subnet (10.0.1.0/24)
    │   ├── Internet Gateway
    │   ├── NAT Gateway
    │   └── Bastion EC2 (Public Access)
    │
    └── Private Subnet (10.0.2.0/24)
        └── Backend EC2 Instances (No direct internet access)

Resource Created

    Networking
        VPC
        Public & Private Subnets
        Internet Gateway
        NAT Gateway (with Elastic IP)
        Route Tables & Associations
    
    Compute
        2 Public EC2 instances (Bastion)
        2 Private EC2 instances (Backend)

    Security
        Public Security Group (SSH from anywhere ⚠️)
        Private Security Group (SSH only from public subnet)


Key Features
    Uses variables for reusability
    Uses count for multiple public instances
    Uses for_each for dynamic private instances
    Implements NAT Gateway for private subnet internet access
    Uses depends_on for dependency control
    Conditional logic:
        var.env == "prod" ? 20 : var.default_root_volume