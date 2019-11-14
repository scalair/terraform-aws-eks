# Terraform AWS EKS
Terraform modules to create an EKS cluster with an administrator user configured.
This module use [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) to create the EKS cluster and use [iam-user](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-user) to create the admin user.
The `iam-user` module required to use [Keybase](https://keybase.io/) to encrypt/decrypt user password, so you need a Keybase account before you can use that module (you can find more details on the [iam-user module page](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-user#notes-for-keybase-users)).

## Prerequisites
A VPC, some subnets and a jumpbox have been previously created. If `eks_alb_attach` is set to true, an ALB must be provided.

## Policies
This module will attach EKS and ECR policies to the admin user and will attach all the required policies to the worker node for basic features to work (ingress and external-dns). At some point, we should use [kube2iam](https://github.com/jtblin/kube2iam) to manage extra permissions.

## Limitations
For now it is impossible to create multiple worker groups using this script. This limitation will soon be addressed.