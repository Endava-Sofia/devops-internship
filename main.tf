provider "aws" {
  # version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    # cidr_block = "10.0.1.0/8"
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_instance" "web" {
  //Example: Find the current Ubuntu Server 16.04 LTS AMI
  //aws ec2 describe-images --owners 099720109477 --filters 'Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-????????' 'Name=state,Values=available' --query 'reverse(sort_by(Images, &CreationDate))[:1].ImageId' --output text
  ami           = "ami-039a49e70ea773ffc"
  instance_type = "t2.micro"

  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
  subnet_id = "${aws_subnet.main.id}"
  
  # depends_on = ["${aws_internet_gateway.gw}"]
}

resource "aws_route_table_association" "r-to-sub" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.r.id}"
}

# resource "aws_route_table_association" "r-to-gw" {
#   gateway_id     = "${aws_internet_gateway.gw.id}"
#   route_table_id = "${aws_route_table.r.id}"
# }


resource "aws_s3_bucket" "endava-devops-intern-bg" {
  bucket = "endava-devops-intern-bg"
  acl    = "private"
}