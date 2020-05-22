provider "aws" {
  # version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_iam_user" "user" {
  name = "testAWSuserLG"
  path = "/"
}

//aws iam add-user-to-group --user-name testAWSuserLG --group-name AdministratorAccess
//aws iam remove-user-from-group --user-name testAWSuserLG --group-name AdministratorAccess

/*
resource "aws_iam_group_membership" "team" {
  name = "tf-testing-group-membership"

  users = [
    "${aws_iam_user.user.name}",
  ]

  group = "${aws_iam_group.group.name}"
}

resource "aws_iam_user_group_membership" "team" {
  user = "${aws_iam_user.user.name}"
  groups = ["${aws_iam_group.group.name}"]
}

// terraform import aws_iam_group.group AdministratorAccess
resource "aws_iam_group" "group" {
  name = "AdministratorAccess"
}
*/