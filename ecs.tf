# Creating an ECS cluster fargate lanch type

resource "aws_ecs_cluster" "ecs" {
  name = "ecs-cluster"

  setting {
    name = "containerInsights"
    value = "enabled"  # enable CloudWatch contenair insights for monitoring
  }
   
  tags = {
    Name = "ecs-cluster"
  }


}

# create a CloudWatch logs group name

resource "aws_cloudwatch_log_group" "ecs-logs" {
  name = "/ecs/ecs-cluster"
  retention_in_days = 30

  tags = {
    Name = "ecs-logs"
  }
}

# create an IAM ROLE to give ECS servcie permission to access other services like ECR to pull docker images....
resource "aws_iam_role" "ecs-role" {
    name = "EcsTaskExcutionRole"

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
}

# creating policy attachement to our role
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# create a task definition
resource "aws_ecs_task_definition" "app" {
    family = "ecommerce-app"
    network_mode = "awsvpc"
    requires_compatibilities = [ "FARGATE" ]
    cpu = "256"
    memory = "512"
    execution_role_arn = aws_iam_role.ecs-role.arn
    container_definitions = jsonencode([
        {
      name  = "nginx"
      image = "nginx:alpine"  # Placeholder - public Nginx image
      essential = true
      
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs-logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "ecommerce-task"
  }
}

# create an application Load Balancer
resource "aws_lb" "ecommerce-alb" {
    name = "ecommerce-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [ aws_security_group.alb-sg.id ]
    subnets = [ for subnet in aws_subnet.public: subnet.id ] # creating in the 2 diffrentes subnets
    enable_deletion_protection = false   # we want to be able to distroy it 

    tags = {
      Name = "ecommerce-alb"
    }

}

# create a target group
resource "aws_alb_target_group" "alb-tg" {
    name = "alb-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
    target_type = "ip"

    health_check {
      enabled = true 
      healthy_threshold = 2 # how many consecutive successeful checks to mark as healthy
      interval = 30  # how many scends form check to check
      matcher = "200"  # only 200 status:code is deemed as heathly
      path = "/"
      port = "traffic-port"
      protocol = "HTTP"
      timeout = 5 # should be less that the interval
      unhealthy_threshold = 3

    }

    tags = {
        Name = "ecommerce-alb-tg"
    }
  
}

# create listner
resource "aws_lb_listener" "alb-listner" {
    load_balancer_arn = aws_lb.ecommerce-alb.arn
    port = 80
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_alb_target_group.alb-tg.arn

    }
}

# create ESC services
resource "aws_ecs_service" "ecs-service" {
    name = "ecs_service"
    cluster = aws_ecs_cluster.ecs.id
    task_definition = aws_ecs_task_definition.app.arn
    desired_count = 2
    launch_type = "FARGATE"

    network_configuration {
    subnets          = [for subnet in aws_subnet.private-subnet : subnet.id]
    security_groups  = [aws_security_group.ecs-sg.id]
    assign_public_ip = false  # Private tasks, no public IPs
  }

   load_balancer {
    target_group_arn = aws_alb_target_group.alb-tg.arn
    container_name   = "nginx"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.alb-listner]

  tags = {
    Name = "ecommerce-service"
  }
}