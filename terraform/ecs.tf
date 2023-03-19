resource "aws_ecs_cluster" "main" {
  name = "demo-cluster"
  tags = {
    Name        = "demo-cluster"
  }
}

#########################################3

resource "aws_ecs_task_definition" "main" {
  family                   = "demo-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
 # task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    name        = "demo-container"
    image       = "026605501970.dkr.ecr.us-east-1.amazonaws.com/demo:latest" #-----------------------------> check
    essential   = true
    #environment = var.container_environment #-----------------------------> check
    portMappings = [{
      protocol      = "tcp"
      containerPort = 3000
      hostPort      = 3000#------------port again
    }]
    # logConfiguration = {
    #   logDriver = "awslogs"
    #   options = {
    #     awslogs-group         = aws_cloudwatch_log_group.main.name
    #     awslogs-stream-prefix = "ecs"
    #     awslogs-region        = var.region
    #   }
    # }
    # secrets = var.container_secrets
  }])

   runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = {
    Name        = "demo-task"
  }
}

####################################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "demo-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


#########################################################

resource "aws_ecs_service" "main" {
  name                               = "demo-service"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
 # health_check_grace_period_seconds  = 60
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id] #-----------------------------> check
    subnets          = [aws_subnet.private.id] #-----------------------------> check
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = "demo-container"
    container_port   = 3000
  }

  # we ignore task_definition changes as the revision changes on deploy
  # of a new version of the application
  # desired_count is ignored as it can change due to autoscaling policy
  # lifecycle {
  #   ignore_changes = [task_definition, desired_count]
  # }
}