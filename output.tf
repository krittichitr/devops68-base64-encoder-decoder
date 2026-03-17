output "app_public_url" {
  value = "http://${aws_instance.nodejs_server.public_ip}:3027"
}