variable "cluster_name" {
    description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
    type        = string
}

variable "cluster_version" {
    description = "Kubernetes version to use for the EKS cluster."
    type        = string
}

variable "subnets" {
    description = "A list of subnets to place the EKS cluster and workers within."
    type        = list(string)
}

variable "vpc_id" {
    description = "VPC where the cluster and workers will be deployed."
    type        = string
}

variable "worker_groups" {
    description = "A list of maps defining worker group configurations to be defined using AWS Launch Configurations. See workers_group_defaults for valid keys."
    type        = any
    default     = []
}

variable "map_roles" {
    description = "Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
    type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
    }))
    default = []
}

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

variable "tags" {
    description = "A map of tags to add to all resources. Tags added to launch coniguration or templates override these values for ASG Tags only."
    type        = map(string)
    default     = {}
}

