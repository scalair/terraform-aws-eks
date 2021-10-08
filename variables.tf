variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type        = string
}

variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
}

variable "worker_groups_defaults" {
  description = "Override default values for target groups."
  type        = map
  default     = {}
}

variable "node_groups_defaults" {
  description = "Map of values to be applied to all node groups."
  type        = map
  default     = {}
}

variable "worker_groups" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Configurations. See workers_group_defaults for valid keys."
  type        = any
  default     = []
}

variable "node_groups" {
  description = "Map of map of node groups to create."
  type        = any
  default     = {}
}

variable "worker_additional_security_groups" {
  description = "A list of additional security groups to attach to worker groups."
  type        = list
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

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type        = list(string)
  default     = []
}

variable "enable_irsa" {
  description = "Whether to create OpenID Connect Provider for EKS to enable IAM Role for Service Account."
  type        = bool
  default     = false
}

variable "irsa_rules" {
  description = "A list of rules to create IAM Roles for Service Accounts."
  type = list(object({
    role_name                 = string,
    service_account_name      = string,
    service_account_namespace = string,
    iam_policy                = string
  }))
  default = []
}

variable "log_types" {
  description = "A list of the desired control plane logging to enable. Possible values are: api, audit, authenticator, controllerManager ans scheduler."
  type        = list(string)
  default     = []
}

variable "log_retention" {
  description = "Number of days to retain log events. Default retention - 90 days."
  type        = number
  default     = 90
}

variable "asg_schedules" {
  description = "A map of all schedules to apply to the autoscaling group."
  type = map(object({
    min_size         = number,
    max_size         = number,
    desired_capacity = number,
    recurrence       = string,
    time_zone        = string
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch coniguration or templates override these values for ASG Tags only."
  type        = map
  default     = {}
}

