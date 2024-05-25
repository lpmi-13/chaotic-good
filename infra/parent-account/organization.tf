resource "aws_organizations_organization" "main" {

  aws_service_access_principals = [
    # we'll want cloudtrail once we need to set up the org trail
    # "cloudtrail.amazonaws.com",
    "sso.amazonaws.com"
  ]

  enabled_policy_types = [
    "AISERVICES_OPT_OUT_POLICY",
    "BACKUP_POLICY",
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY",
  ]

  feature_set = "ALL"
}


resource "aws_organizations_organizational_unit" "chaotic-good" {
  name      = "chaotic-good"
  parent_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_account" "chaotic-good" {
  name = "chaotic-good"
  # pull this out to a variable later
  # since you can't re-use an email address if/when you close an account, make sure
  # that all your testing is complete before you settle on the final value for this
  email = "chaotic-admin+test@chaotic-good.org"

  # Enables IAM users to access account billing information
  # if they have the required permissions
  iam_user_access_to_billing = "ALLOW"

  tags = {
    Name  = "chaotic-good"
    Owner = "Admin von Admin"
    Role  = "chaos"
  }

  parent_id = aws_organizations_organizational_unit.chaotic-good.id
}

# use this when we're ready to set up a test role that shouldn't be able to do anything "admin"
# data "aws_iam_policy_document" "example" {
#   statement {
# effect    = "Deny"
# actions   = ["iam:*", "ec2:*", "rds:*"]
# resources = ["arn:aws:iam::*:role/role-to-deny"]
#   }
# }
# 
# resource "aws_organizations_policy" "example" {
#   name    = "example"
#   content = data.aws_iam_policy_document.example.json
#   type    = "SERVICE_CONTROL_POLICY"
# }
