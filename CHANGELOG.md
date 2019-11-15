# Changelog

## v1.3.2 - 2019-11-14
### Added
- Add `iam_user_arn` to outputs

## v1.3.1 - 2019-11-14
### Fixed
- Fix ALB remote state conditional

## v1.3.0 - 2019-11-14
### Added
- Possibility to attach an existing ALB to a worker group

## v1.2.2 - 2019-11-06
### Added
- Add `eks_cluster_create_timeout` and `eks_cluster_delete_timeout` variables

## v1.2.1 - 2019-10-18
### Changed
- Add missing outputs for terraform-aws-modules/eks/aws

## v1.2.0 - 2019-10-14
### Added
- Create an additional SG to be able to SSH from the jumpbox and enable ICMP.

## v1.1.0 - 2019-10-10
### Added
- Add `provider.tf` to fix `aws` provider version to `2.31.0`

### Changed
- Update `terraform-aws-modules/eks/aws` to `6.0.2`

## v1.0.5 - 2019-09-04
### Changed
- Add missing policies `elasticloadbalancing:AddListenerCertificates` and `elasticloadbalancing:DescribeListenerCertificates`

## v1.0.4 - 2019-08-12
### Changed
- Set default value for variables `iam_user_pgp_key` and `iam_user_name`

## v1.0.3 - 2019-08-09
### Changed
- Make `aws_iam_user_policy_attachment` policies conditional with `iam_user_create_user`

## v1.0.2 - 2019-08-09
### Added
- Add `iam_user_create_user` variable

## v1.0.1 - 2019-08-02
### Changed
- Remove unnecessary policies for admin user
- Add missing policies to worker role

## v1.0.0 - 2019-08-02
### Added
- Initial commit
