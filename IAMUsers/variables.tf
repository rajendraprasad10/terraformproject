variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "dev_bucket_name" {
  description = "S3 bucket name used by developers (full access)"
  type        = string
  default     = "my-org-dev-bucket"
}

variable "test_bucket_name" {
  description = "S3 test bucket name used by testers (read-only)"
  type        = string
  default     = "my-org-test-bucket"
}

variable "automation_user_name" {
  description = "IAM username for automation systems (programmatic access)"
  type        = string
  default     = "automation.system"
}

# optional pgp_key variable if you want to encrypt access key in terraform output
# variable "pgp_key" {
#   description = "PGP key to encrypt access key secret in state"
#   type = string
#   default = ""
# }
