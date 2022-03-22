output "trusted_account_id" {
  value = data.aws_caller_identity.this_account.account_id
}
output "trusting_account_id" {
  value = data.aws_caller_identity.trusting_account.account_id
}

output "trusting_account_cross_account_role_arn" {
  value =  aws_iam_role.cross_account_role.arn
}
output "trusting_account_cross_account_role_name" {
  value =  aws_iam_role.cross_account_role.name
}
output "trusting_account_cross_account_role_unique_id" {
  value =  aws_iam_role.cross_account_role.unique_id
}

output "trusting_account_cross_account_policy_arn" {
  value =  aws_iam_policy.cross_account_role_policy.arn
}
output "trusting_account_cross_account_policy_name" {
  value =  aws_iam_policy.cross_account_role_policy.name
}
output "trusting_account_cross_account_policy_id" {
  value =  aws_iam_policy.cross_account_role_policy.id
}

output "cross_account_access_principals" {
  value = local.cross_account_access_principals
}

output "switch_role_url" {
    value = "https://signin.aws.amazon.com/switchrole?roleName=${aws_iam_role.cross_account_role.name}&account=${data.aws_caller_identity.trusting_account.account_id}"
}