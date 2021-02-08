# Terraform AWS EKS

Terraform modules to create an EKS cluster with an IAM administrator user configured.

This module use the official [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) to create the EKS cluster and use [iam-user](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-user) to create the admin user.

**The `iam-user` module required to use [Keybase](https://keybase.io/) to encrypt/decrypt user password/key**, so you need a Keybase account before you can use that module (you can find more details on the [iam-user module page](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-user#notes-for-keybase-users)).

## Prerequisites

Some prerequisites are mandatories to create the EKS cluster :

- VPC with subnets.
- a PGP keypair. Either a base64 encoded PGP pubkey, or [use Keybase](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-user#notes-for-keybase-users)

## Usage

```bash
module "eks" {
    source = "github.com/scalair/terraform-aws-eks"

    cluster_name = "eks-tools"
    cluster_version = "1.17"

    vpc_id = "vpc-0034032d3885717f4"
    subnets = [
        "subnet-0a75753db1l0v370u",
        "subnet-03ad134r370ua1337"
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
            name = "elasticsearch"
            asg_desired_capacity    = 3
            asg_max_size            = 3
            asg_min_size            = 3
            instance_type           = "m5.large"

            key_name                = "eks-ec2_ro_dc"
            kubelet_extra_args      = "--node-labels=env=prod,workload=elasticsearch --register-with-taints=env=prod:NoSchedule,workload=elasticsearch:NoSchedule"

            k8s_labels = {
                environment = "prod"
                workload    = "elasticsearch"
            }
        },
        {
            name = "common"
            asg_desired_capacity    = 2
            asg_max_size            = 3
            asg_min_size            = 2
            instance_type           = "c5.large"

            k8s_labels = {
                environment = "prod"
                workload    = "common"
            }
        }
    ]

    # Example of IAM Role for Service Account
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

    tags = {
        "environment" = "dev"
        "client"      = "scalair"
    }
}
```
