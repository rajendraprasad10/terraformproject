resource "aws_iam_policy" "terraform_state_policy" {
  name        = "TerraformStateAccess"
  description = "IAM policy for Terraform backend access"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::my-terraform-state-bucket-dev"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::my-terraform-state-bucket-dev/*"
      }
    ]
  })
}
