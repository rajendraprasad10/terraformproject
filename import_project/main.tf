# steps to do 
# create a directory import_project
# cd import_project
# create a file main.tf
# add this 
# provider "aws" {
  
#   region = "us-east-1"

# }


# # import {
# #   id = "i-0325e664ea27cfa9f"

# #   to = aws_instance.demo-server
# # }


# terraform init 

# terraform plan -generate-config-out=generated_resources.tf

# terraform import aws_instance.demo-server i-0325e664ea27cfa9f

# terraform plan 

# verify the resource is imported successfully

# After running the above commands, you should see that the resource has been successfully imported into your Terraform state.

# Now, you can copy the generated resource configuration from generated_resources.tf

# and paste it into your main.tf file to manage the resource with Terraform.

# The final main.tf file should look like this after you


# write a challenges .tf file to import the resource



provider "aws" {
  
  region = "us-east-1"

}


# import {
#   id = "i-0325e664ea27cfa9f"

#   to = aws_instance.demo-server
# }

# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "aws_instance" "demo-server" {
  ami                                  = "ami-068c0051b15cdb816"
  availability_zone                    = "us-east-1f"
  disable_api_stop                     = false
  disable_api_termination              = false
  ebs_optimized                        = true
  force_destroy                        = false
  get_password_data                    = false
  hibernation                          = false
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t3.micro"
  key_name                             = "linux-key"
  monitoring                           = false
  placement_partition_number           = 0
  region                               = "us-east-1"
  tags = {
    Name = "demo-server"
  }
  tags_all = {
    Name = "demo-server"
  }
  tenancy                     = "default"
  user_data                   = null
  user_data_replace_on_change = null
  volume_tags                 = null
  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }
  cpu_options {
    core_count       = 1
    threads_per_core = 2
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  enclave_options {
    enabled = false
  }
  maintenance_options {
    auto_recovery = "default"
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled"
  }
  
  private_dns_name_options {
    enable_resource_name_dns_a_record    = true
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 3000
    tags                  = {}
    tags_all              = {}
    throughput            = 125
    volume_size           = 8
    volume_type           = "gp3"
  }
}
