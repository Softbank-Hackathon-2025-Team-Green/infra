terraform {

  cloud {
    organization = "softbank-hackathon-2025-team-green"
    workspaces {
      name = "infra"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

data "aws_caller_identity" "current" {}

module "ssm" {
  source     = "./modules/ssm"
  account_id = data.aws_caller_identity.current.account_id
}

module "network" {
  source              = "./modules/network"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  az                  = "ap-northeast-2a"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "k3s_control_plane" {
  source = "./modules/k3s-control-plane"

  subnet_id            = module.network.private_subnet_id
  security_group_id    = module.network.security_group_id
  instance_type        = "t3.small"
  ami_id               = data.aws_ami.ubuntu.id
  iam_instance_profile = module.ssm.instance_profile_name
}

module "k3s_worker_asg" {
  source = "./modules/k3s-worker"

  private_subnet_id    = module.network.private_subnet_id
  security_group_id    = module.network.security_group_id
  ami_id               = data.aws_ami.ubuntu.id
  instance_type        = "t3.small"
  desired_capacity     = 1
  min_size             = 1
  max_size             = 4
  iam_instance_profile = module.ssm.instance_profile_name
  server_private_ip    = module.k3s_control_plane.control_plane_private_ip

  depends_on = [
    module.k3s_control_plane
  ]
}
