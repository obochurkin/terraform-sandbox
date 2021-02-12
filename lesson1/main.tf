#VARIABLES 
#passing variables to tf script, example aws credentials
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "aws_region" {}


#PROVIDERS

#descripe to terraform where we want to deploy
provider "aws" {
  access_key = var.aws_access_key //var means we take values from variable
  secret_key = var.aws_secret_key
  region = var.aws_region
}

#DATA

#recieves actual data from provider, example created IDs or existing recources
data "aws_ami" "aws-linux2" {
  most_recent = true
  owners = [ "amazon" ]

  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-x86_64-gp2" ]
  }

  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }

  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}

#RESOURCES

#notifying terraform to use default vpc (existing one) instead of creating a new one
#also this gives possibility fetch vpc data example id
resource "aws_default_vpc" "default" {
  
}

#creates sequrity group
# here allowed incomong to port 22 and 80 from cpecific cidr
resource "aws_security_group" "allow_ssh" {
  name = ""
  description = "value"
  vpc_id = aws_default_vpc.default.id

  ingress {
    cidr_blocks = [ "45.89.88.228/32" ]
    description = "allows port 22 be accesable only from defined cidr"
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }

  ingress {
    cidr_blocks = [ "45.89.88.228/32" ]
    description = "allows port 80 be accesable only from defined cidr"
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }

  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = -1
    to_port = 0
  }
}

# provisoning instance
resource "aws_instance" "nginx" {
  ami = data.aws_ami.aws-linux2.id #gets filtered id of the ami
  instance_type = "t2.micro"
  key_name = var.key_name #gets from vars
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]  #this id will be filled from the resource security group defined above
  #describing ssh connection to instance
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private_key_path)
  }

  # this will be run on instance start
  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install nginx1 -y",  #probably specific of linux2 ami-s
      "sudo service nginx start"
    ]
  }
}

#OUTPUT
output "aws_instance_public_dns" {
  value = aws_instance.nginx.public_dns
}