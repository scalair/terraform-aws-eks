# Create a user to administrate the cluster
module "iam_user" {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-user?ref=v2.1.0"

  name          = var.iam_user_name
  pgp_key       = var.iam_user_pgp_key
  force_destroy = var.iam_user_force_destroy
  create_user   = var.iam_user_create_user

  tags = var.tags
}

# Admin policies to access cluster
resource "aws_iam_user_policy_attachment" "AmazonEKSServicePolicy" {
  count = var.iam_user_create_user ? 1 : 0

  user       = module.iam_user.this_iam_user_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_user_policy_attachment" "AmazonEKSClusterPolicy" {
  count = var.iam_user_create_user ? 1 : 0

  user       = module.iam_user.this_iam_user_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_user_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  count = var.iam_user_create_user ? 1 : 0

  user       = module.iam_user.this_iam_user_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Additional SG for worker nodes
resource "aws_security_group" "worker_nodes" {
  description = "Allow SSH from the jumpbox and ICMP to worker nodes"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "jumpbox_ingress" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.jumpbox.outputs.aws_security_group_id

  security_group_id = aws_security_group.worker_nodes.id
}

resource "aws_security_group_rule" "alb_ingress" {
  count = var.eks_alb_attach ? 1 : 0

  type                     = "ingress"
  from_port                = var.eks_alb_port
  to_port                  = var.eks_alb_port
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.alb.outputs.load_balancer_security_group_id

  security_group_id = aws_security_group.worker_nodes.id
}

resource "aws_security_group_rule" "icmp_ingress" {
  type        = "ingress"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.worker_nodes.id
}

resource "aws_security_group_rule" "all_egress" {
  type         = "egress"
  from_port    = 0
  to_port      = 0
  protocol     = "-1"
  cidr_blocks  = ["0.0.0.0/0"]

  security_group_id = aws_security_group.worker_nodes.id
}

locals {
  local_worker_group = merge(
    var.eks_worker_groups.0,
    var.eks_alb_attach ? {target_group_arns = data.terraform_remote_state.alb.outputs.target_group_arns} : {}
  )
}

# Create the EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "6.0.2"

  cluster_name                         = var.eks_cluster_name
  cluster_version                      = var.eks_cluster_version
  subnets                              = data.terraform_remote_state.subnet.outputs.private_subnets
  vpc_id                               = data.terraform_remote_state.vpc.outputs.vpc_id
  worker_additional_security_group_ids = [aws_security_group.worker_nodes.id]
  worker_groups                        = [local.local_worker_group]
  config_output_path                   = var.eks_config_output_path
  write_aws_auth_config                = var.eks_write_aws_auth_config
  write_kubeconfig                     = var.eks_write_kubeconfig

  map_users = [
    {
      userarn  = module.iam_user.this_iam_user_arn
      username = module.iam_user.this_iam_user_name
      groups   = ["system:masters"]
    },
  ]

  tags = var.tags
}

# Policies to allow services in Kubernetes to manage AWS resources such as LB, certs, DNS, ... 
resource "aws_iam_policy" "worker" {
  name        = "worker.${var.eks_cluster_name}"
  path        = "/"
  description = "Policies for worker nodes of ${var.eks_cluster_name}"

  policy = file("worker-policy.json")
}

resource "aws_iam_role_policy_attachment" "worker-attach" {
  role       = module.eks.worker_iam_role_name
  policy_arn = aws_iam_policy.worker.arn
}