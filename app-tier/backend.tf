terraform {
  backend "s3" {
    bucket         = "rajendra-s3-demo-xyz" # change this
    key            = "raj/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile = true
  }
}