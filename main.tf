# Configure the AWS Provider
# Provider URL - https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

# Creating a EC2 instance
resource "aws_instance" "terraform-ec2" {
  ami           = "ami-0e35ddab05955cf57" # Ubuntu Server 24.04 LTS (HVM) (64-bit (x86)), SSD Volume Type
  instance_type = "t3.micro"
  key_name               = aws_key_pair.terraform_key.key_name # Associate key pair
  vpc_security_group_ids = [aws_security_group.allowed_ports.id] # Use the new SG

  root_block_device {
    volume_size = 10  # Increase root volume to 20GB
    volume_type = "gp3"  # Use GP3 (latest SSD)
    delete_on_termination = true  # Delete volume when instance terminates
  }

  metadata_options {
  http_endpoint               = "enabled"
  http_tokens                = "required"
  http_put_response_hop_limit = 1
 }

  tags = {
    Name = "MyTerraformInstance"
  }
}

# Creating SSH key pair for EC2 instance
# ------------------------------------------------------------------
# Create a new key pair or import an existing one
resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-ec2"
  public_key = file("~/.ssh/terraform-ec2.pub") # Path to your public key file

  # You can directly put the public key here if you don't want to use a file
  # public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

# Security Group to allow SSH
resource "aws_security_group" "allowed_ports" {
  name        = "allowed_ports"
  description = "Allow inbound traffic on specific ports"
  
  # SSH ingress rule (Outside world to the instance)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from anywhere (adjust for your needs)
  }

  # ICMP rule for ping (Outside world to the instance)
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] # Allow ping from anywhere (adjust for your needs)
  }
  
  # HTTP rule for web server (Outside world to the instance)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow ping from anywhere (adjust for your needs)
  }
  
  # HTTPS rule for web server (Outside world to the instance)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow ping from anywhere (adjust for your needs)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allowed_ports"
  }
}
# ------------------------------------------------------------------

# Ability to stat and stop the EC2 instance
# ------------------------------------------------------------------
# Null Resource to Start the EC2 Instance
resource "null_resource" "start_ec2_instance" {
  provisioner "local-exec" {
    command = "aws ec2 start-instances --instance-ids ${aws_instance.terraform-ec2.id}"
  }
}
# To start the instance using terraform, run:
# terraform apply -target null_resource.start_ec2_instance

# Null Resource to Stop the EC2 Instance
resource "null_resource" "stop_ec2_instance" {
  provisioner "local-exec" {
    command = "aws ec2 stop-instances --instance-ids ${aws_instance.terraform-ec2.id}"
  }
}
# To stop the instance using terraform, run:
# terraform apply -target null_resource.stop_ec2_instance
# ------------------------------------------------------------------
