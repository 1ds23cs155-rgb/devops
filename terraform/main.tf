terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "tourism" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tourism-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.tourism.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "tourism-public-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.tourism.id
  cidr_block        = "10.0.${count.index + 11}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "tourism-private-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "tourism" {
  vpc_id = aws_vpc.tourism.id

  tags = {
    Name = "tourism-igw"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.tourism.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.tourism.id
  }

  tags = {
    Name = "tourism-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Group for Load Balancer
resource "aws_security_group" "alb" {
  name        = "tourism-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.tourism.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tourism-alb-sg"
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "tourism-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.tourism.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tourism-ecs-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "tourism" {
  name               = "tourism-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = {
    Name = "tourism-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "tourism" {
  name        = "tourism-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.tourism.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/health"
    matcher             = "200,301,302"
  }

  tags = {
    Name = "tourism-tg"
  }
}

# ALB Listener
resource "aws_lb_listener" "tourism" {
  load_balancer_arn = aws_lb.tourism.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tourism.arn
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "tourism" {
  name = "tourism-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "tourism-cluster"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "tourism" {
  name              = "/ecs/tourism-website"
  retention_in_days = 7

  tags = {
    Name = "tourism-logs"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "tourism" {
  family                   = "tourism-website"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "tourism-website"
      image     = "${var.container_image}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.tourism.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "wget --quiet --tries=1 --spider http://localhost/health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 5
      }
    }
  ])

  tags = {
    Name = "tourism-task"
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "tourism-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "tourism-ecs-role"
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Service
resource "aws_ecs_service" "tourism" {
  name            = "tourism-service"
  cluster         = aws_ecs_cluster.tourism.id
  task_definition = aws_ecs_task_definition.tourism.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tourism.arn
    container_name   = "tourism-website"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.tourism]

  tags = {
    Name = "tourism-service"
  }
}

# Auto Scaling Target
resource "aws_appautoscaling_target" "tourism" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.tourism.name}/${aws_ecs_service.tourism.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy - CPU
resource "aws_appautoscaling_policy" "tourism_cpu" {
  name               = "tourism-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.tourism.resource_id
  scalable_dimension = aws_appautoscaling_target.tourism.scalable_dimension
  service_namespace  = aws_appautoscaling_target.tourism.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

# Auto Scaling Policy - Memory
resource "aws_appautoscaling_policy" "tourism_memory" {
  name               = "tourism-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.tourism.resource_id
  scalable_dimension = aws_appautoscaling_target.tourism.scalable_dimension
  service_namespace  = aws_appautoscaling_target.tourism.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80.0
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
