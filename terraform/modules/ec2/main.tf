resource "aws_security_group" "ec2_sg" {
  name        = "wiz-sg"
  description = "Allow SSH and MongoDB"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MongoDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow from VPC CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wiz-sg"
  }
}

resource "aws_instance" "mongo" {
  ami                    = "ami-0c7217cdde317cfec" # Ubuntu 23.04 in us-east-1
  instance_type          = "t3.medium"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = "wiz-profile"

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    s3_bucket = var.s3_bucket
  })

  tags = {
    Name = "wiz-mongo"
  }
} 