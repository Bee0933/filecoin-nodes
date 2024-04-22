

# key pair for SSH
resource "aws_key_pair" "my-key-pair" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")
}


resource "aws_instance" "forest-instance" {
  ami           = "ami-080e1f13689e07408" # use Ubuntu AMI
  instance_type = "t3.large"
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = aws_key_pair.my-key-pair.key_name

  # hello world oin port 80
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World!" > index.html
    nohup busybox httpd -f -p 80 &
    EOF

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
  instance_type = "t3.2xlarge"
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = aws_key_pair.my-key-pair.key_name

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World!" > index.html
    nohup busybox httpd -f -p 80 &
    EOF

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
  key_name      = aws_key_pair.my-key-pair.key_name

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World!" > index.html
    nohup busybox httpd -f -p 80 &
    EOF

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
  key_name      = aws_key_pair.my-key-pair.key_name

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