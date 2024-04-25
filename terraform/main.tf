
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

resource "aws_instance" "lotus-instance" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t3.large"
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = var.key-name

  tags = {
    Name = "lotus-instance"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 512 # 512 GiB SSD
    delete_on_termination = true
  }

  vpc_security_group_ids = [aws_security_group.filecoin-public-sn-sg.id]

}

resource "aws_instance" "monitoring-instance" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t3.large"
  subnet_id     = module.vpc.public_subnets[1]
  key_name      = var.key-name

  tags = {
    Name = "monitoring-instance"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 128 # 128 GiB SSD
    delete_on_termination = true
  }

  vpc_security_group_ids = [aws_security_group.monitoring-public-sn-sg.id]
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
  ami                = "ami-080e1f13689e07408"
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.public_subnets[1]
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
    command = "ansible-playbook  --inventory ${aws_instance.forest-instance.public_ip}, --private-key ${var.ssh-private-key-path} --user ubuntu  forest_setup.yaml --extra-vars 'loki_address=${aws_instance.monitoring-instance.public_ip}'"
  }

}