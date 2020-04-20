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
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "second" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1c"
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
    # cidr_blocks = ["${aws_vpc.main.cidr_block}"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
	user_data = "${data.template_file.init.rendered}"

  associate_public_ip_address = true
  # key_name   = "${aws_key_pair.deployer.key_name}"
  key_name   = "deployer-key2"

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

data "template_file" "init" {
  template = "${file("${path.module}/init.tpl")}"
  vars = {
    bucket_name = "${aws_s3_bucket.endava-devops-intern-bg.bucket}"
    # key_name = "${aws_s3_bucket_object.file_upload.key}"
    key_name = "my_bucket_key"
  }
}

resource "aws_s3_bucket_object" "file_upload" {
  bucket = "${aws_s3_bucket.endava-devops-intern-bg.bucket}"
  # key    = "${data.template_file.init.vars[key_name]}"
  key    = "my_bucket_key"
  content = "${data.template_file.init.rendered}"
}


resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.test_role.name}"
}

# resource "aws_key_pair" "deployer" {
#   key_name   = "deployer-key"
#   public_key = ""
# }

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.test_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_ecr_repository" "repo" {
  name                 = "docker_repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_eks_cluster" "eks" {
  name     = "eks"
  role_arn = "${aws_iam_role.eks_role.arn}"

  vpc_config {
    subnet_ids = ["${aws_subnet.main.id}", "${aws_subnet.second.id}"]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSServicePolicy,
  ]
}

# output "endpoint" {
#   value = "${aws_eks_cluster.eks.endpoint}"
# }

# output "kubeconfig-certificate-authority-data" {
#   value = "${aws_eks_cluster.eks.certificate_authority.0.data}"
# }


resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks_role.name}"
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks_role.name}"
}