provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_iam_user" "lb" {
  name = "testAWSuserLG"
  path = "/"
}

//aws iam add-user-to-group --user-name testAWSuserLG --group-name AdministratorAccess
/*
resource "aws_iam_group_membership" "team" {
  name = "tf-testing-group-membership"

  users = [
    "${aws_iam_user.user.name}",
  ]

  group = "${aws_iam_group.admins.name}"
}

resource "aws_iam_group" "admins" {
  name = "AdministratorAccess"
}

resource "aws_iam_user" "user" {
  name = "testAWSuserLG"
}
*/
