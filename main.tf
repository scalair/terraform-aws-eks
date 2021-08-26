module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  for_each = { for i, v in var.worker_additional_security_groups : i => v }

  name        = each.value.name
  description = "EKS additional security group"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [for ingress in lookup(each.value, "ingress", []) : ingress if lookup(ingress, "cidr_blocks", null) != null]
  egress_with_cidr_blocks  = [for egress in lookup(each.value, "egress", []) : egress if lookup(egress, "cidr_blocks", null) != null]

  ingress_with_source_security_group_id = [for ingress in lookup(each.value, "ingress", []) : ingress if lookup(ingress, "source_security_group_id", null) != null]
  egress_with_source_security_group_id  = [for egress in lookup(each.value, "egress", []) : egress if lookup(egress, "source_security_group_id", null) != null]

  tags = var.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 17.1"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id  = var.vpc_id
  subnets = var.subnets

  workers_group_defaults = var.worker_groups_defaults
  node_groups_defaults   = var.node_groups_defaults

  worker_groups = var.worker_groups
  node_groups   = var.node_groups

  worker_additional_security_group_ids = [for sg in module.security_group : sg.this_security_group_id]

  worker_create_cluster_primary_security_group_rules = length(var.worker_groups) > 0 && length(var.node_groups) > 0

  map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts

  enable_irsa = var.enable_irsa

  cluster_enabled_log_types     = var.log_types
  cluster_log_retention_in_days = var.log_retention

  tags = var.tags
}

# Kubernetes Provider

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Autoscaling Groups schedules

# Create a list of autoscaling groups objects from both node groups and worker groups
locals {

  node_group_asg_names = flatten([
    for k, group in module.eks.node_groups : [group.resources[0].autoscaling_groups[0].name]
  ])

  asg_names = concat(module.eks.workers_asg_names, local.node_group_asg_names)

  local_asg_schedules = flatten([
    for i, asg_name in local.asg_names : [
      for schedule_name, schedule in var.asg_schedules : {
        name                   = schedule_name
        min_size               = schedule.min_size
        max_size               = schedule.max_size
        desired_capacity       = schedule.desired_capacity
        recurrence             = schedule.recurrence
        autoscaling_group_name = asg_name
      }
    ]
  ])
}

resource "aws_autoscaling_schedule" "asg_schedules" {
  for_each = { for i, v in local.local_asg_schedules : i => v }

  scheduled_action_name  = each.value.name
  min_size               = each.value.min_size
  max_size               = each.value.max_size
  desired_capacity       = each.value.desired_capacity
  recurrence             = each.value.recurrence
  autoscaling_group_name = each.value.autoscaling_group_name
}

# IAM Roles for Service Accounts

module "iam_assumable_role_admin" {
  for_each = { for v in var.irsa_rules : v.role_name => v }

  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 3.0"
  create_role                   = true
  role_name                     = each.value.role_name
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.iam_policy[each.key].arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${each.value.service_account_namespace}:${each.value.service_account_name}"]
}

resource "aws_iam_policy" "iam_policy" {
  for_each = { for v in var.irsa_rules : v.role_name => v }

  name_prefix = each.value.role_name
  description = "Policy for EKS cluster ${module.eks.cluster_id}"
  policy      = each.value.iam_policy
}
