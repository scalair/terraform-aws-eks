locals {
	iam_user_name = var.iam_user_name == "" ? "admin_${var.cluster_name}" : var.iam_user_name 
}

module "iam_user" {
	source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-user?ref=v3.4.0"

	name				= local.iam_user_name
	pgp_key       		= var.iam_user_pgp_key
	force_destroy 		= var.iam_user_force_destroy
	create_user   		= var.iam_user_create_user

	tags				= var.tags
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

module "eks" {
	source          = "terraform-aws-modules/eks/aws"
	cluster_name    = var.cluster_name
	cluster_version = var.cluster_version
	subnets         = var.subnets
	vpc_id          = var.vpc_id

	worker_groups 	= var.worker_groups

	map_users = [
	{
		userarn  = module.iam_user.this_iam_user_arn
		username = module.iam_user.this_iam_user_name
		groups   = ["system:masters"]
	}
	]

	tags			= var.tags
}
