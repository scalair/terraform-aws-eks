data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    region = "${var.vpc_state_region}"
    bucket = "${var.vpc_bucket}"
    key    = "${var.vpc_state_key}"
  }
}

data "terraform_remote_state" "subnet" {
  backend = "s3"

  config = {
    region = "${var.subnet_state_region}"
    bucket = "${var.subnet_bucket}"
    key    = "${var.subnet_state_key}"
  }
}
