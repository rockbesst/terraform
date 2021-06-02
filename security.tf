# Security Groups#########################################
data "aws_security_group" "mainSecGroup" {
 id = "sg-0ef96a12de408930c"
}
# IAM ###################################################

 resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  path = "/"

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
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2_policy"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow"
		    "Action" = "s3:*"
        "Resource" = ["arn:aws:s3:::rockbesst-img", "arn:aws:s3:::rockbesst-img/*"]
      },
    ]
  })
}