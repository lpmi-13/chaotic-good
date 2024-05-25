resource "aws_organizations_organization" "main" {

  # we might want a few other principals once everything is up and running, but this is fine for now
  aws_service_access_principals = [
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
