output forst-instance-ip {
  value       = aws_instance.forest-instance.public_ip
  sensitive   = false
  description = "forest instace public IP"
}


output lotus-instance-ip {
  value       = aws_instance.lotus-instance.public_ip
  sensitive   = false
  description = "Lotus instace public IP"
}

output monitoring-instance-ip {
  value       = aws_instance.monitoring-instance.public_ip
  sensitive   = false
  description = "Monitoring instace public IP"
}


output nginx-instance-ip {
  value       = aws_instance.nginx-instance.public_ip
  sensitive   = false
  description = "Nginx instace public IP"
}