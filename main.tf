terraform {
  required_providers {
      aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5"
      configuration_aliases = [
          aws.trusting_account
      ]
    }
  }
}

data "aws_iam_group" "groups" {
  count = length(var.attach_sts_assume_role_access_policy_to_iam_group_names)
  group_name = var.attach_sts_assume_role_access_policy_to_iam_group_names[count.index]
}

data "aws_iam_user" "users" {
  count = length(var.attach_sts_assume_role_access_policy_to_iam_user_names)
  user_name = var.attach_sts_assume_role_access_policy_to_iam_user_names[count.index]
}

data "aws_iam_role" "roles" {
  count = length(var.attach_sts_assume_role_access_policy_to_iam_role_names)
  name = var.attach_sts_assume_role_access_policy_to_iam_role_names[count.index]
}


locals {
    cross_account_access_principals = concat(
        flatten([
            for group in data.aws_iam_group.groups : [ for user in group.users : user.arn ] if var.add_cross_account_access_principal_groups_members
        ]),
        [
            for user in data.aws_iam_user.users : user.arn
        ],
        [
            for role in data.aws_iam_role.roles : role.arn
        ],
    )
}

data "aws_caller_identity" "this_account" {
}

data "aws_caller_identity" "trusting_account" {
  provider = aws.trusting_account
}

resource "random_uuid" "uuids" {
  count = 3
}

resource "aws_iam_user_policy_attachment" "attachment" {
  count = var.attach_sts_assume_role_access_policy_in_trusted_account ? length(var.attach_sts_assume_role_access_policy_to_iam_user_names) : 0
  user      = var.attach_sts_assume_role_access_policy_to_iam_user_names[count.index]
  policy_arn = aws_iam_policy.cross_account_role_access_policy.arn
}

resource "aws_iam_group_policy_attachment" "attachment" {
  count = var.attach_sts_assume_role_access_policy_in_trusted_account ? length(var.attach_sts_assume_role_access_policy_to_iam_group_names) : 0
  group      = var.attach_sts_assume_role_access_policy_to_iam_group_names[count.index]
  policy_arn = aws_iam_policy.cross_account_role_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "attachment" {
  count = var.attach_sts_assume_role_access_policy_in_trusted_account ? length(var.attach_sts_assume_role_access_policy_to_iam_role_names) : 0
  role = var.attach_sts_assume_role_access_policy_to_iam_role_names[count.index]
  policy_arn = aws_iam_policy.cross_account_role_access_policy.arn
}

resource "aws_iam_policy" "cross_account_role_access_policy" {
  name   = replace(random_uuid.uuids[0].id, "-", "")
  path   = var.iam_policy_path == "" ? "/" : var.iam_policy_path
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole"
            ],
            "Effect": "Allow",
            "Resource": "${aws_iam_role.cross_account_role.arn}"
        }
    ]
  }
  EOF
}

resource "aws_iam_role" "cross_account_role" {
  provider = aws.trusting_account
  name  = var.cross_account_role_name == "" ? replace(random_uuid.uuids[2].id, "-", "") : var.cross_account_role_name
  assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
          {
              Action = "sts:AssumeRole"
              Effect = "Allow"
              Sid    = ""
              Principal = {
                  AWS = var.provide_cross_account_access_to_this_caller ? distinct(concat(local.cross_account_access_principals, tolist([data.aws_caller_identity.this_account.arn]))) : local.cross_account_access_principals
              }
          }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "cross_account_role_policy_attachment" {
  provider = aws.trusting_account
  role = aws_iam_role.cross_account_role.name
  policy_arn = aws_iam_policy.cross_account_role_policy.arn
}

resource "aws_iam_policy" "cross_account_role_policy" {
  provider = aws.trusting_account
  name   = replace(random_uuid.uuids[1].id, "-", "")
  path   = var.iam_policy_path == "" ? "/" : var.iam_policy_path
  policy = var.cross_account_iam_role_policy_document
}
