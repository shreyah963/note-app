output "instance_id" { value = aws_instance.mongo.id }
output "public_ip" { value = aws_instance.mongo.public_ip }
output "private_ip" { value = aws_instance.mongo.private_ip } 