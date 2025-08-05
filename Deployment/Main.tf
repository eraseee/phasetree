terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region     = "eu-central-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = local.required_tags
}

resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = local.required_tags
}


//Image repo
resource "aws_ecr_repository" "image_repo" {
  name                 = "image-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = local.required_tags
}


data "aws_ecr_image" "service_image" {
  repository_name = aws_ecr_repository.image_repo.name
  image_tag       = "latest"
}




//Cluster
resource "aws_kms_key" "kms_key" {
  description             = "kms-key"
  deletion_window_in_days = 7
  tags = local.required_tags
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name_prefix = var.log_group_prefix
  tags = local.required_tags
}

resource "aws_ecs_cluster" "cluster" {
  name = "esc-cluster"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.kms_key.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.cloudwatch_log_group.name
      }
    }
  }

  tags = local.required_tags
}
resource "aws_ecs_task_definition" "web_task" {
  family = "service"
  #Need to fix environment variables
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = data.aws_ecr_image.service_image.image_uri
      cpu       = var.ecs_cpu_usage[var.Env]
      memory    = var.ecs_memory_usage[var.Env]
      essential = true
      environment = [{"name":"PORT", "value": var.port[var.Env]}]
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "web_service" {
  name            = "web_service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.web_task.arn
  desired_count   = var.ecs_task_count[var.Env]
  iam_role        = aws_iam_role.iam_role.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.load_balancer_target_group.arn
    container_name   = "web_service"
    container_port   = 8080
  }
}



resource "aws_eks_fargate_profile" "fargate_profile" {
  cluster_name           = aws_ecs_cluster.cluster.name
  fargate_profile_name   = "example"
  pod_execution_role_arn = aws_iam_role.iam_role.arn
  subnet_ids             = aws_subnet.main_subnet[*].id

  selector {
    namespace = "example"
  }
  tags = local.required_tags
}



//IAM 
resource "aws_iam_group" "developers" {
  name = "mathiasGroup"
  path = "/users/"
}

resource "aws_iam_role" "iam_role" {
  name = "iam_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = local.required_tags
}


//Load balancer, have removed access logs from this, as it required security groups.
resource "aws_lb" "load_balancer" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.main_subnet.id]

  enable_deletion_protection = true

  tags = local.required_tags
}

resource "aws_lb_target_group" "load_balancer_target_group" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}