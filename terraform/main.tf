
# EC2 Instance for Forest Node
resource "aws_instance" "forest-instance" {
  ami           = "ami-080e1f13689e07408" # use Ubuntu AMI
  instance_type = "t3.large"
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = var.key-name

  tags = {
    Name = "forest-instance"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 128 # 128 GiB SSD
    delete_on_termination = true
  }

  vpc_security_group_ids = [aws_security_group.filecoin-public-sn-sg.id]

}

# EC2 Instance for Lotus Node
resource "aws_instance" "lotus-instance" {
  ami           = "ami-0eac975a54dfee8cb" # use ubuntu arm 
  instance_type = "t4g.2xlarge"
  # availability_zone = "us-east-1b"
  subnet_id = module.vpc.public_subnets[0]
  key_name  = var.key-name

  tags = {
    Name = "lotus-instance"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 512 # 512 GiB SSD
    delete_on_termination = true
  }

  vpc_security_group_ids = [aws_security_group.filecoin-public-sn-sg.id]

}

# EC2 Instance for Monitoring Nodes
resource "aws_instance" "monitoring-instance" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t3.large"
  subnet_id     = module.vpc.public_subnets[1]
  key_name      = var.key-name

  tags = {
    Name = "monitoring-instance_1"
  }

  # IAM Role  profile for EC2 to S3 access
  iam_instance_profile = aws_iam_instance_profile.monitior-instance-s3-profile.name

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 128 # 128 GiB SSD
    delete_on_termination = true
  }

  vpc_security_group_ids = [aws_security_group.monitoring-public-sn-sg.id]
}


# IAM instance profile for Monitoring Nodes ( S3 Access )
resource "aws_iam_instance_profile" "monitior-instance-s3-profile" {
  name = "MonitiorInstanceS3Profile"
  role = aws_iam_role.monitior-instance-s3-role.name
}

resource "aws_iam_role" "monitior-instance-s3-role" {
  name = "monitior-instance-s3-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.monitior-instance-s3-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


# S3 Bucket for monitoring instance
resource "aws_s3_bucket" "fil-monitoring-s3-bucket" {
  bucket = "fil-monitoring-s3-bucket"

  tags = {
    Name = "fil-monitoring-s3-bucket"
  }
}


# Nginx Reverse Proxy Instance
resource "aws_instance" "nginx-instance" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnets[1]
  key_name      = var.key-name

  tags = {
    Name = "nginx-instance"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 128 # 128 GiB SSD
    delete_on_termination = true
  }

  vpc_security_group_ids = [aws_security_group.monitoring-public-sn-sg.id]

}


# ansible installs
resource "null_resource" "configure-servers" {
  # forest instance
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = var.ssh-user
      private_key = file(var.ssh-private-key-path)
      host        = aws_instance.forest-instance.public_ip
    }
  }

  provisioner "local-exec" {
    working_dir = "../ansible"
    command     = "ansible-playbook  --inventory ${aws_instance.forest-instance.public_ip}, --private-key ${var.ssh-private-key-path} --user ubuntu  forest_setup.yaml --extra-vars 'monitor_host=${aws_instance.monitoring-instance.public_ip}'"
  }

  # lotus instance
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = var.ssh-user
      private_key = file(var.ssh-private-key-path)
      host        = aws_instance.lotus-instance.public_ip
    }
  }

  provisioner "local-exec" {
    working_dir = "../ansible"
    command     = "ansible-playbook  --inventory ${aws_instance.lotus-instance.public_ip}, --private-key ${var.ssh-private-key-path} --user ubuntu  lotus_setup.yaml --extra-vars 'monitor_host=${aws_instance.monitoring-instance.public_ip}'"
  }


  # monitoring instance
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = var.ssh-user
      private_key = file(var.ssh-private-key-path)
      host        = aws_instance.monitoring-instance.public_ip
    }
  }

  provisioner "local-exec" {
    working_dir = "../ansible"
    command     = "ansible-playbook  --inventory ${aws_instance.monitoring-instance.public_ip}, --private-key ${var.ssh-private-key-path} --user ubuntu  monitor_instance_setup.yaml --extra-vars 'monitor_host=${aws_instance.monitoring-instance.public_ip} slack_webhook=${var.slack-webhook} s3_bucket_name=${aws_s3_bucket.fil-monitoring-s3-bucket.bucket} s3_region=${var.aws-region} forsest_node_ip=${aws_instance.forest-instance.public_ip} lotus_node_ip=${aws_instance.lotus-instance.public_ip}'"
  }


  # install promtail on forest instance
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = var.ssh-user
      private_key = file(var.ssh-private-key-path)
      host        = aws_instance.forest-instance.public_ip
    }
  }

  provisioner "local-exec" {
    working_dir = "../ansible"
    command     = "ansible-playbook  --inventory ${aws_instance.forest-instance.public_ip}, --private-key ${var.ssh-private-key-path} --user ubuntu  promtail_forest_louts_setup.yaml --extra-vars 'monitor_host=${aws_instance.monitoring-instance.public_ip}'"
  }



  # install promtail on Lotus instance
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = var.ssh-user
      private_key = file(var.ssh-private-key-path)
      host        = aws_instance.lotus-instance.public_ip
    }
  }

  provisioner "local-exec" {
    working_dir = "../ansible"
    command     = "ansible-playbook  --inventory ${aws_instance.lotus-instance.public_ip}, --private-key ${var.ssh-private-key-path} --user ubuntu  promtail_forest_louts_setup.yaml --extra-vars 'monitor_host=${aws_instance.monitoring-instance.public_ip}'"
  }



  # install and setup nginx instance
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = var.ssh-user
      private_key = file(var.ssh-private-key-path)
      host        = aws_instance.nginx-instance.public_ip
    }
  }

  provisioner "local-exec" {
    working_dir = "../ansible"
    command     = "ansible-playbook  --inventory ${aws_instance.nginx-instance.public_ip}, --private-key ${var.ssh-private-key-path} --user ubuntu  setup_nginx.yaml --extra-vars 'monitor_host=${aws_instance.monitoring-instance.public_ip}'"
  }

}


