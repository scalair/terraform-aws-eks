########################################
# Module terraform-aws-modules/eks/aws #
########################################
output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_version" {
  value = module.eks.cluster_version
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "config_map_aws_auth" {
  value = module.eks.config_map_aws_auth
}

output "cluster_iam_role_name" {
  value = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  value = module.eks.cluster_iam_role_arn
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "cloudwatch_log_group_name" {
  value = module.eks.cloudwatch_log_group_name
}

output "kubeconfig" {
  value = module.eks.kubeconfig
}

output "kubeconfig_filename" {
  value = module.eks.kubeconfig_filename
}

output "workers_asg_arns" {
  value = module.eks.workers_asg_arns
}

output "workers_asg_names" {
  value = module.eks.workers_asg_names
}

output "workers_user_data" {
  value = module.eks.workers_user_data
}

output "workers_default_ami_id" {
  value = module.eks.workers_default_ami_id
}

output "workers_launch_template_ids" {
  value = module.eks.workers_launch_template_ids
}

output "workers_launch_template_arns" {
  value = module.eks.workers_launch_template_arns
}

output "workers_launch_template_latest_versions" {
  value = module.eks.workers_launch_template_latest_versions
}

output "worker_security_group_id" {
  value = module.eks.worker_security_group_id
}

output "worker_iam_instance_profile_arns" {
  value = module.eks.worker_iam_instance_profile_arns
}

output "worker_iam_instance_profile_names" {
  value = module.eks.worker_iam_instance_profile_names
}

output "worker_iam_role_name" {
  value = module.eks.worker_iam_role_name
}

output "worker_iam_role_arn" {
  value = module.eks.worker_iam_role_arn
}

output "worker_autoscaling_policy_name" {
  value = module.eks.worker_autoscaling_policy_name
}

output "worker_autoscaling_policy_arn" {
  value = module.eks.worker_autoscaling_policy_arn
}

##################################################
# Module terraform-aws-modules/terraform-aws-iam #
##################################################
output "iam_access_key_id" {
  value = module.iam_user.this_iam_access_key_id
}

output "iam_access_key_encrypted_secret" {
  value = module.iam_user.this_iam_access_key_encrypted_secret
}

output "keybase_secret_key_decrypt_command" {
  value = module.iam_user.keybase_secret_key_decrypt_command
}
