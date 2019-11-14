data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    region = var.vpc_state_region
    bucket = var.vpc_bucket
    key    = var.vpc_state_key
  }
}

data "terraform_remote_state" "subnet" {
  backend = "s3"

  config = {
    region = var.subnet_state_region
    bucket = var.subnet_bucket
    key    = var.subnet_state_key
  }
}

data "terraform_remote_state" "jumpbox" {
  backend = "s3"

  config = {
    region = var.jumpbox_state_region
    bucket = var.jumpbox_bucket
    key    = var.jumpbox_state_key
  }
}

data "terraform_remote_state" "alb" {
  count = var.eks_alb_attach ? 1 : 0

  backend = "s3"

  config = {
    region = var.alb_state_region
    bucket = var.alb_bucket
    key    = var.alb_state_key
  }
}