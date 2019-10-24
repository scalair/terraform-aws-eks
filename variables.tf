variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

####################
# VPC remote state #
####################
variable "vpc_bucket" {
  description = "Name of the bucket where vpc state is stored"
  type        = string
}

variable "vpc_state_key" {
  description = "Key where the state file of the VPC is stored"
  type        = string
}

variable "vpc_state_region" {
  description = "Region where the state file of the VPC is stored"
  type        = string
}

#######################
# Subnet remote state #
#######################
variable "subnet_bucket" {
  description = "Name of the bucket where subnet state is stored"
  type        = string
}

variable "subnet_state_key" {
  description = "Key where the state file of the subnet is stored"
  type        = string
}

variable "subnet_state_region" {
  description = "Region where the state file of the subnet is stored"
  type        = string
}

#######################
# jumpbox remote state #
#######################
variable "jumpbox_bucket" {
  description = "Name of the bucket where jumpbox state is stored"
  type        = string
}

variable "jumpbox_state_key" {
  description = "Key where the state file of the jumpbox is stored"
  type        = string
}

variable "jumpbox_state_region" {
  description = "Region where the state file of the jumpbox is stored"
  type        = string
}

####################
# ALB remote state #
####################
variable "alb_bucket" {
  description = "Name of the bucket where ALB state is stored"
  type        = string
}

variable "alb_state_key" {
  description = "Key where the state file of the ALB is stored"
  type        = string
}

variable "alb_state_region" {
  description = "Region where the state file of the ALB is stored"
  type        = string
}

##################################################
# Module terraform-aws-modules/terraform-aws-iam #
##################################################
variable "iam_user_pgp_key" {
  description = "Either a base-64 encoded PGP public key, or a keybase username in the form keybase:username. Used to encrypt password and access key."
  type        = string
  default     = ""
}

variable "iam_user_name" {
  description = "Desired name for the IAM user"
  type        = string
  default     = ""
}

variable "iam_user_force_destroy" {
  description = "When destroying this user, destroy even if it has non-Terraform-managed IAM access keys, login profile or MFA devices. Without force_destroy a user with non-Terraform-managed access keys and login profile will fail to be destroyed."
  type        = bool
  default     = true
}

variable "iam_user_create_user" {
  description = "Whether to create the IAM user"
  type        = bool
  default     = true
}


########################################
# Module terraform-aws-modules/eks/aws #
########################################
variable "eks_cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
}
variable "eks_cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

variable "eks_config_output_path" {
  description = "Where to save the Kubectl config file (if `write_kubeconfig = true`). Should end in a forward slash `/` ."
  type        = string
  default     = "./"
}

variable "eks_write_kubeconfig" {
  description = "Whether to write a Kubectl config file containing the cluster configuration. Saved to `config_output_path`."
  type        = bool
  default     = false
}

variable "eks_write_aws_auth_config" {
  description = "Whether to write the aws-auth configmap file."
  type        = bool
  default     = false
}

variable "eks_worker_groups" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Configurations. See workers_group_defaults for valid keys."
  type        = any
  default     = []
}

variable "eks_alb_attach" {
  description = "If true, Terraform will use remote state to associate an ALB with the cluster"
  type        = bool
  default     = false
}