terraform {}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "trusting_account"
  region = "us-east-1"
  profile = "joshhawks-io"
}

module "cross_account" {
    source = "../"
    providers = {
        aws.trusting_account = aws.trusting_account
    }

    attach_sts_assume_role_access_policy_in_trusted_account = true
    attach_sts_assume_role_access_policy_to_iam_group_names = [
        "administrators"
    ]
}

output "switch_role_url" {
    value = module.cross_account.switch_role_url
}

output "cross_account_access_principals" {
    value = module.cross_account.cross_account_access_principals
}