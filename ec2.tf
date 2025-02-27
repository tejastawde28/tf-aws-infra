resource "aws_instance" "webapp" {
  ami           = var.custom_ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [
    aws_security_group.app_sg.id,
  ]
  key_name  = var.key_name
  subnet_id = aws_subnet.private[0].id

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }

  disable_api_termination = false
}
