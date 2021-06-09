# Security Groups#########################################
data "aws_security_group" "mainSecGroup" {
 id = "sg-0ef96a12de408930c"
}
# IAM ###################################################

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.for_ec2.json
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

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}


resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2_policy"
  role = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.for_rol.json
}

data "aws_iam_policy_document" "for_rol" {
  statement {
    effect = "Allow"
    actions = [ "s3:Get*","s3:List*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      =  ["${aws_iam_role.ec2_role.name}"]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_s3_bucket_policy" "buc_policy" {
  bucket = aws_s3_bucket.rockbesst-img.id
  policy = data.aws_iam_policy_document.for_buc.json
}

data "aws_iam_policy_document" "for_buc" {
  statement {
    effect = "Allow"
    principals  { 
      type = "AWS"    
      identifiers = [ aws_iam_role.ec2_role.arn ]
    }
    actions = [ "s3:GetObject"]
    resources = [
      "${aws_s3_bucket.rockbesst-img.arn}/*"
    ]
  }

  # statement {
  #   effect = "Deny"
  #   not_principals  { 
  #     type = "AWS"    
  #     identifiers = [format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id), 
  #     aws_iam_role.test_role.arn]

  #   }
  #   actions = [ "s3:ListBucket" ]
  #   resources = [
  #     aws_s3_bucket.mandr-web-res.arn
  #   ]
}