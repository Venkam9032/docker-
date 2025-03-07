resource "aws_instance" "this" {
  ami                    = "ami-09c813fb71547fc4f" # This is our devops-practice AMI ID
  vpc_security_group_ids = [aws_security_group.allow_all_docker.id]
  instance_type          = "t3.micro"

  # 20GB is not enough
  root_block_device {
    volume_size = 50  # Set root volume size to 50GB
    volume_type = "gp3"  # Use gp3 for better performance (optional)
  }

  # user_data = file("docker.sh")
  # tags = {
  #   Name    = "docker"
  # }

  # Copy and execute the script manually if user_data fails
  provisioner "file" {
    source      = "docker.sh"
    destination = "/home/ec2-user/docker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/docker.sh",
      "sudo /home/ec2-user/docker.sh"
    ]
  }

  tags = {
    Name = "docker"
  }

  # Ensure SSH connection for provisioners
  connection {
    type        = "ssh"
    user        = "ec2-user"
     # Change this to your key fileke
    password= "DevOps321"
    host        = self.public_ip
  }
}



resource "aws_security_group" "allow_all_docker" {
  name        = "allow_all_docker"
  description = "Allow TLS inbound traffic and all outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
output "docker_ip" {
  value       = aws_instance.this.public_ip
}