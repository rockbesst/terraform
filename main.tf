provider "aws" {
	region = var.region
}
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
# Security Groups#########################################
data "aws_security_group" "mainSecGroup" {
 id = "sg-0ef96a12de408930c"
}
# VPCs#####################################################
data "aws_vpc" "mainVPC" {}
# Load Balancer############################################
resource "aws_lb" "MainLoadBalancer" {
 	name = "MainLoadBalancer"
 	load_balancer_type = "application"
 	security_groups = [data.aws_security_group.mainSecGroup.id]
 	subnets = [data.aws_subnet.sub1.id, data.aws_subnet.sub2.id]
}

 resource "aws_lb_listener" "listener_http" {
   load_balancer_arn = aws_lb.MainLoadBalancer.arn
   port              = "80"
   protocol          = "HTTP"
   default_action {
     type             = "forward"
     target_group_arn = aws_lb_target_group.tg_main.arn
   }
 }
 resource "aws_lb_target_group" "tg_main" {
 	name     = "MainTargetGroup"
   	port     = 80
   	protocol = "HTTP"
   	vpc_id   = data.aws_vpc.mainVPC.id
 }
 resource "aws_lb_target_group_attachment" "attach1_to_tg_main" {
 	target_group_arn = aws_lb_target_group.tg_main.arn
  	target_id        = aws_instance.WebServer1.id
   	port             = 80
  
 }
 resource "aws_lb_target_group_attachment" "attach2_to_tg_main" {
 	target_group_arn = aws_lb_target_group.tg_main.arn
  	target_id        = aws_instance.WebServer2.id
   	port             = 80  
 }

 # Subnets
 data "aws_subnet" "sub1"{
	 id = "subnet-0c95ec66"
 }
 data "aws_subnet" "sub2"{
	 id = "subnet-ad3c88d1"
 }