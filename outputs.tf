########################################
# Module terraform-aws-modules/eks/aws #
########################################
output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = "${module.eks.cluster_id}"
}

output "worker_iam_role_name" {
  value = "${module.eks.worker_iam_role_name}"
}

output "worker_iam_role_arn" {
  value = "${module.eks.worker_iam_role_arn}"
}

output "workers_asg_names" {
  value = "${module.eks.workers_asg_names}"
}

##################################################
# Module terraform-aws-modules/terraform-aws-iam #
##################################################
output "iam_access_key_id" {
  value = "${module.iam_user.this_iam_access_key_id}"
}

output "iam_access_key_encrypted_secret" {
  value = "${module.iam_user.this_iam_access_key_encrypted_secret}"
}

output "keybase_secret_key_decrypt_command" {
  value = "${module.iam_user.keybase_secret_key_decrypt_command}"
}
