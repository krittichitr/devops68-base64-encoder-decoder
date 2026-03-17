provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "app_sg" {
  name_prefix = "app_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3027
    to_port     = 3027
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

resource "aws_instance" "nodejs_server" {
  ami                    = "ami-080e1f13689e07408"
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
              sudo apt-get install -y nodejs git
              
              cd /home/ubuntu
              git clone https://github.com/krittichitr/devops68-base64-encoder-decoder.git myapp
              cd myapp
              npm install
              nohup npm start > app.log 2>&1 &
              EOF

  user_data_replace_on_change = true
}

output "instance_public_ip" {
  value = aws_instance.nodejs_server.public_ip
}