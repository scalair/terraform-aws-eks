# Create a user to administrate the cluster
module "iam_user" {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-user?ref=v2.1.0"

  name          = var.iam_user_name
  pgp_key       = var.iam_user_pgp_key
  force_destroy = var.iam_user_force_destroy

  tags = var.tags
}

# Admin policies to access cluster
resource "aws_iam_user_policy_attachment" "AmazonEKSServicePolicy" {
  user       = module.iam_user.this_iam_user_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_user_policy_attachment" "AmazonEKSClusterPolicy" {
  user       = module.iam_user.this_iam_user_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_user_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  user       = module.iam_user.this_iam_user_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Create the EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "5.1.0"

  cluster_name          = var.eks_cluster_name
  cluster_version       = var.eks_cluster_version
  subnets               = data.terraform_remote_state.subnet.outputs.private_subnets
  vpc_id                = data.terraform_remote_state.vpc.outputs.vpc_id
  worker_groups         = var.eks_worker_groups
  config_output_path    = var.eks_config_output_path
  write_aws_auth_config = var.eks_write_aws_auth_config
  write_kubeconfig      = var.eks_write_kubeconfig

  map_users = [
    {
      user_arn = module.iam_user.this_iam_user_arn
      username = module.iam_user.this_iam_user_name
      group    = "system:masters"
    },
  ]

  tags = var.tags
}

# Policies to allow services in Kubernetes to manage AWS resources such as LB, certs, DNS, ... 
resource "aws_iam_policy" "worker" {
  name        = "worker.${var.eks_cluster_name}"
  path        = "/"
  description = "Policies for worker nodes of ${var.eks_cluster_name}"

  policy = "${file("worker-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "worker-attach" {
  role       = module.eks.worker_iam_role_name
  policy_arn = aws_iam_policy.worker.arn
}