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

    manage_aws_auth     = true
    iam_user_pgp_key    = "keybase:scalair_pce"

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

    tags = {
        "environment" = "dev"
        "client"      = "scalair"
    }
}
```

## User authentication & authorization

The module creates a IAM user that has admin privileges within the EKS cluster.

It also attaches the following AWS built-in policies to the admin user :

- `AmazonEKSServicePolicy`
- `AmazonEKSClusterPolicy`
- `AmazonEKSWorkerNodePolicy`

Once the cluster has been deployed, you can ***retrieve IAM credentials*** :

```bash
terraform output iam_access_key_id
terraform output iam_access_key_encrypted_secret
```

The `iam_access_key_encrypted_secret` is actually base64 encrypted, so you can decrypt it using the configured PGP keypair.

For example, here is how to decrypt it with your Keybase PGP keypair :

```bash
export KEYBASE_USERNAME=keybase_user
export KEYBASE_PAPERKEY=keybase_paperkey
export KEYBASE_PASSPHRASE=keybase_passphrase

terraform output iam_access_key_encrypted_secret|base64 -d|keybase pgp decrypt
```

## Limitations

- `node_groups` : only `worker_groups` are supported