# Instances#############################################
resource "aws_instance" "WebServer1" {
	ami = data.aws_ami.amazon_linux.id
	instance_type = var.instance_type
	availability_zone = "eu-central-1a"
	vpc_security_group_ids = [data.aws_security_group.mainSecGroup.id]
	user_data = file("ready_webserver.sh")
	key_name = var.ssh_key
	associate_public_ip_address = var.allow_public_ip
	tags = merge(var.tags, {Name = "WebServer1"})
    iam_instance_profile = aws_iam_instance_profile.test_profile.name
}
resource "aws_instance" "WebServer2" {
	ami = data.aws_ami.amazon_linux.id
	instance_type = var.instance_type
	availability_zone = "eu-central-1b"
	vpc_security_group_ids = [data.aws_security_group.mainSecGroup.id]
	user_data = file("ready_webserver.sh")
	key_name = var.ssh_key
	associate_public_ip_address = var.allow_public_ip
	tags = merge(var.tags, {Name = "WebServer2"})
	iam_instance_profile = aws_iam_instance_profile.test_profile.name
}
# AMI Search
data "aws_ami" "amazon_linux" {
	owners = ["amazon"]
	most_recent = true
	filter {
		name = "name"
		values = ["amzn2-ami-hvm-*-x86_64-gp2"]
	}
}

resource "aws_iam_role" "test_role" {
  name = "test_role"
  assume_role_policy = data.aws_iam_policy_document.for_ec2.json

  tags = {
      tag-key = "tag-value"
  }
}

data "aws_iam_policy_document" "for_ec2" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals  { 
      type = "Service"
      identifiers = ["ec2.amazonaws.com"] 
    }
  }
}


resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.test_role.name
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.test_role.id

  policy = data.aws_iam_policy_document.for_rol.json
}

data "aws_iam_policy_document" "for_rol" {
  statement {
    effect = "Allow"
    actions = [ "s3:Get*","s3:List*"]
    resources = ["*"]
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.rockbesst-test.id

  policy = data.aws_iam_policy_document.for_buc.json

}
data "aws_iam_policy_document" "for_buc" {
  statement {
    effect = "Allow"
    principals  { 
      type = "AWS"    
      identifiers = [ aws_iam_role.test_role.arn ]
    }
    actions = [ "s3:GetObject"]
    resources = [
      "${aws_s3_bucket.rockbesst-test.arn}/*"
    ]
  }

  statement {
    effect = "Deny"
    not_principals  { 
      type = "AWS"    
      identifiers = [format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id), 
      aws_iam_role.test_role.arn]

    }
    actions = [ "s3:ListBucket" ]
    resources = [
      aws_s3_bucket.rockbesst-test.arn
    ]
}

}
data "aws_caller_identity" "current" {}
