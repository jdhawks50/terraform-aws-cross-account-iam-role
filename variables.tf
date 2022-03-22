variable "iam_policy_path" {
  type = string
  default = ""
}

variable "attach_sts_assume_role_access_in_trusted_account" {
  type = bool
  default = false
}
variable "cross_account_role_name" {
  type = string
  default = ""
}
variable "provide_cross_account_access_to_this_caller" {
  type = bool
  default = true
}
variable "cross_account_access_principal" {
  type = string
  default = ""
}
variable "cross_account_iam_role_policy_document" {
  type = string
  default = <<-JSON
  {
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
  }
  JSON
}


variable "attach_sts_assume_role_access_policy_to_iam_group_names" {
    type = list(string)
    default = []
}
variable "attach_sts_assume_role_access_policy_to_iam_role_names" {
    type = list(string)
    default = []
}
variable "attach_sts_assume_role_access_policy_to_iam_user_names" {
    type = list(string)
    default = []
}
variable "attach_sts_assume_role_access_policy_in_trusted_account" {
    type = bool
    default = false
}
variable "attach_sts_assume_role_access_policy_to_current_caller" {
    type = bool
    default = false
}
variable "add_cross_account_access_principal_groups_members" {
    type = bool
    default = true
}