# security group to allow internt traffic to the Application Loadbalancer


resource "aws_security_group" "alb-sg" {
    name = "alb-sg"
    description = "This security group allow HTTP trafic to the ALB"
    vpc_id = aws_vpc.main.id

    #  http form  anywhere
    ingress  {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    #https form anywhere
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # allow inbound trafic to call API and do helth check
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" # all protocals
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "alb-sg"
    }
}



# Security group to allow traffic to ECS only from the alb-sg

resource "aws_security_group" "ecs-sg" {
    name = "ecs-sg"
    description = " this security group all traffic to reach containers but only through the Application Load balancer"
    vpc_id = aws_vpc.main.id

    # allow  Http from alb-sg
    ingress  {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb-sg.id]

    }

    # allow all outbound traffic to all ecs task to call API
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
     tags = {
       Name = "ecs-sg"
     }
}

# security to all traffic to the Database

resource "aws_security_group" "db-sg" {
    name = "db-sg"
    description = " this security group all traffic to the database but only though the ecs-sg"
    vpc_id = aws_vpc.main.id

    # all http from ecs
    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [aws_security_group.ecs-sg.id]
    }
  
    # no outboud for the Database but aws ask for at leat one 

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = []
    }

    tags = {
        Name = "db-sg"
    }
}

resource "aws_security_group_rule" "db-rule" {
    description = "Allow ECS to talk to the database"
    type = "ingress"
    to_port = 5043
    from_port = 5043
    protocol = "tcp"
    security_group_id = aws_security_group.db-sg.id
    source_security_group_id = aws_security_group.ecs-sg.id
  
}