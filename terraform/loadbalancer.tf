resource "aws_security_group" "alb" {
  name   = "demo-sg-alb"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "demo-sg-alb"
  }
}

##############################################

resource "aws_lb" "main" {
  name               = "demo-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public.id,aws_subnet.public2.id]

  enable_deletion_protection = false

  tags = {
    Name        = "demo-alb"
  }
}

resource "aws_alb_target_group" "main" {
  name        = "demo-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      =  aws_vpc.main.id
  target_type = "ip"


  tags = {
    Name        = "demo-tg"
  }

}

# Redirect to https listener
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

 default_action {
        target_group_arn = aws_alb_target_group.main.id
        type             = "forward"
    }
}