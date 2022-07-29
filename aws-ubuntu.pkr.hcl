packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "lab-ami-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "eu-west-1"
  vpc_id        = "vpc-04fdf08d31a95112d"
  subnet_id     = "subnet-0a50bba37c19b0625"
  deprecate_at  = "2023-07-29T18:00:00Z"
  ssh_timeout   = "8m"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "lab-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "ansible" {
    playbook_file = "./playbooks/apache2.yml"
  }
}