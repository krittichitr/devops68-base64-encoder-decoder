variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "key_name" {
  type    = string
  default = "my-terraform-key"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}