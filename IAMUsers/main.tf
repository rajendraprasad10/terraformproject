terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ---------- Groups ----------
resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_group" "devops" {
  name = "devops"
}

resource "aws_iam_group" "testers" {
  name = "testers"
}

resource "aws_iam_group" "admins" {
  name = "admins"
}

# ---------- Managed policy attachments ----------
# DevOps needs broad managed access: IAM, EC2, S3, RDS
resource "aws_iam_group_policy_attachment" "devops_iam" {
  group      = aws_iam_group.devops.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}
resource "aws_iam_group_policy_attachment" "devops_ec2" {
  group      = aws_iam_group.devops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
resource "aws_iam_group_policy_attachment" "devops_s3" {
  group      = aws_iam_group.devops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_group_policy_attachment" "devops_rds" {
  group      = aws_iam_group.devops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

# Admin -> full AdministratorAccess (use only for trusted admins)
resource "aws_iam_group_policy_attachment" "admins_admin" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Developer: read-only for EC2 (AWS managed read-only) + full access to specific dev S3 bucket (custom)
resource "aws_iam_group_policy_attachment" "developers_ec2_readonly" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# Tester: allow CloudWatch logs read + read-only access to specific test S3 bucket (custom)
# We'll create custom policies below for dev S3 and tester S3 + CloudWatch read

# ---------- Custom policies ----------
data "aws_caller_identity" "current" {}

# Developer S3 policy (full on dev bucket only)
resource "aws_iam_policy" "developer_s3_policy" {
  name        = "DeveloperS3Access-${replace(var.dev_bucket_name, "/", "-")}"
  description = "Full S3 access to the development bucket only"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "DevBucketFullAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:PutObjectAcl",
          "s3:GetObjectAcl"
        ]
        Resource = [
          "arn:aws:s3:::${var.dev_bucket_name}",
          "arn:aws:s3:::${var.dev_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "developers_s3_attach" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developer_s3_policy.arn
}

# Tester policy: CloudWatch Logs read + S3 read-only for test bucket
resource "aws_iam_policy" "tester_cloudwatch_s3_policy" {
  name        = "TesterCloudWatchAndS3Read-${replace(var.test_bucket_name, "/", "-")}"
  description = "Read access to CloudWatch Logs and read-only access to the test S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "CloudWatchLogsRead"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:TestMetricFilter",
          "logs:GetLogRecord"
        ]
        Resource = "*"
      },
      {
        Sid = "TestBucketReadOnly"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.test_bucket_name}",
          "arn:aws:s3:::${var.test_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "testers_policy_attach" {
  group      = aws_iam_group.testers.name
  policy_arn = aws_iam_policy.tester_cloudwatch_s3_policy.arn
}

# ---------- Users ----------
# Example users. In production you may want to create users by for_each from a map.
resource "aws_iam_user" "alice_dev" {
  name = "alice.developer"
  tags = { role = "developer" }
}

resource "aws_iam_user" "bob_devops" {
  name = "bob.devops"
  tags = { role = "devops" }
}

resource "aws_iam_user" "carol_tester" {
  name = "carol.tester"
  tags = { role = "tester" }
}

resource "aws_iam_user" "dave_admin" {
  name = "dave.admin"
  tags = { role = "admin" }
}

# Add users to groups
resource "aws_iam_user_group_membership" "alice_dev_group" {
  user = aws_iam_user.alice_dev.name
  groups = [
    aws_iam_group.developers.name
  ]
}

resource "aws_iam_user_group_membership" "bob_devops_group" {
  user = aws_iam_user.bob_devops.name
  groups = [
    aws_iam_group.devops.name
  ]
}

resource "aws_iam_user_group_membership" "carol_testers_group" {
  user = aws_iam_user.carol_tester.name
  groups = [
    aws_iam_group.testers.name
  ]
}

resource "aws_iam_user_group_membership" "dave_admins_group" {
  user = aws_iam_user.dave_admin.name
  groups = [
    aws_iam_group.admins.name
  ]
}

# Optionally create an access key for an automation user (use with caution)
resource "aws_iam_user" "automation" {
  name = var.automation_user_name
  tags = { role = "automation" }
}

resource "aws_iam_user_group_membership" "automation_group" {
  user = aws_iam_user.automation.name
  groups = [
    aws_iam_group.devops.name
  ]
}

# Create access key for automation user. Save the secret safely (this shows once).
resource "aws_iam_access_key" "automation_key" {
  user = aws_iam_user.automation.name

  # Optional: PGP key can be used to encrypt the secret in the state output
  # pgp_key = var.pgp_key  # uncomment if using PGP for state security
}

# ---------- Outputs ----------
output "user_arns" {
  description = "ARNs of example users"
  value = {
    alice    = aws_iam_user.alice_dev.arn
    bob      = aws_iam_user.bob_devops.arn
    carol    = aws_iam_user.carol_tester.arn
    dave     = aws_iam_user.dave_admin.arn
    automation = aws_iam_user.automation.arn
  }
}

# Output access key values - show once on apply; store securely.
output "automation_access_key" {
  description = "Access key id and secret for automation user - store securely"
  value = {
    id     = aws_iam_access_key.automation_key.id
    secret = aws_iam_access_key.automation_key.secret
  }
  sensitive = true
}
