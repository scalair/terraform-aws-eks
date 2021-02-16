# Terraform AWS EKS

Terraform modules to create an EKS cluster.

This module use the official [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) to create the EKS cluster.

## Prerequisites

Some prerequisites are mandatories to create the EKS cluster :

- VPC with subnets

## Usage

```bash
module "eks" {
    source = "github.com/scalair/terraform-aws-eks"

    cluster_name = "eks-tools"
    cluster_version = "1.17"

    vpc_id = "vpc-xxxxxxxxxxxxxxxx"
    subnets = [
        "subnet-xxxxxxxxxxxxxxxx",
        "subnet-xxxxxxxxxxxxxxxx"
    ]
    
    // This user must be created beforehand with the following permissions:
    // AmazonEKSClusterPolicy, AmazonEKSWorkerNodePolicy, AmazonEKSServicePolicy
    map_users = [
        {
            userarn  = "arn:aws:iam::xxxxxxxxxxxx:user/eks-admin"
            username = "eks-admin"
            groups   = ["system:masters"]
        }
    ]

    node_groups = {
        main = {
            desired_capacity = 3
            max_capacity     = 10
            min_capacity     = 3
            instance_types   = ["t3a.small"]
            capacity_type    = "SPOT" # or ON_DEMAND
        }
    }

    worker_groups = [
        {
            name = "worker1"
            asg_desired_capacity    = 3
            asg_max_size            = 3
            asg_min_size            = 3
            instance_type           = "m5.large"
        },
        {
            name = "worker2"
            asg_desired_capacity    = 2
            asg_max_size            = 3
            asg_min_size            = 2
            instance_type           = "c5.large"
        }
    ]

    # Example of IAM Roles for Service Accounts
    enable_irsa = true
    irsa_rules = [
        {
            role_name                 = "cluster-autoscaler"
            service_account_name      = "cluster-autoscaler"
            service_account_namespace = "kube-system"
            iam_policy                = "{...}"
        }
    ]

    # You can attach additional security groups to worker groups (but not node groups)
    worker_additional_security_groups = [
        {
            name = "additional-eks-sg",
            ingress_rules = [
                {
                    from_port   = 32323
                    to_port     = 32323
                    protocol    = "tcp"
                    description = "HTTP"
                    cidr_blocks = "0.0.0.0/0"
                }
            ]
        }
    ]

    # Schedules apply to all Autoscaling Groups
    asg_schedules = {
        "startup" = {
            min_size         = "2"
            max_size         = "10"
            desired_capacity = "5"
            recurrence       = "0 7 * * 1-5"
        },
        "shutdown" = {
            min_size         = "0"
            max_size         = "0"
            desired_capacity = "0"
            recurrence       = "0 18 * * 1-5"
        },
    }

    tags = {}
}
```
