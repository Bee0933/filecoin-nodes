
# VPC for filecoin implementation (Forest & Lotus)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "filecoin-vpc"

  cidr = "10.0.0.0/16"

  azs            = var.azs #["us-east-1a"] 
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
}


resource "aws_security_group" "filecoin-public-sn-sg" {
  name        = "filecoin-public-sn-sg"
  description = "Security group for public filecoin subnet"
  vpc_id      = module.vpc.vpc_id

  # Ingress rules for SSH (Port 22), Filecoin Forest (Port 1234/2345), Filecoin Lotus (Port 6665),
  # Node Exporter (Port 9100), and Promtail Agent (Port 9080)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1234 # Port for Filecoin Forest RPC communication
    to_port     = 1234
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2345 # Port for Filecoin Forest metrics collection
    to_port     = 2345
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6665 # Port for Filecoin Lotus
    to_port     = 6665
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100 # Port for Node Exporter
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9080 # Port for Promtail Agent
    to_port     = 9080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "monitoring-public-sn-sg" {
  name        = "monitoring-public-sn-sg"
  description = "Security group for public monitoring subnet"
  vpc_id      = module.vpc.vpc_id

  # Ingress rules for SSH (Port 22), Loki (Port 3100), Grafana (Port 3000),
  # Prometheus (Port 9090), Alertmanager (Port 9093), and Nginx (Port 80)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3100 # Port for Loki
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000 # Port for Grafana
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090 # Port for Prometheus
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9093 # Port for Alertmanager
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80 # Port for Nginx
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
