# generate a random password
resource "random_password" "db-password" {
    length = 8
    special = false # for dev it is not necessairy
    upper = true
    lower = true
    numeric = true
  
}

# create the secretemanager secrete
resource "aws_secretsmanager_secret" "db-password" {
    name = "ecommerce/db-password"
    description = "this is the database's password"
    
    tags = {
      Name = "db-password"
    }
}

#this is the actual password (for ratation)
resource "aws_secretsmanager_secret_version" "db-password" {
    secret_id = aws_secretsmanager_secret.db-password.id
    secret_string = random_password.db-password.result
}

# create RDS subnet groups
resource "aws_db_subnet_group" "db-subnet-group" {
    name = "ecommerce-db-subnet"
    description = "these are the pivate subnets where i will host my database "
    subnet_ids = [ for subnet in aws_subnet.private-subnet: subnet.id ]

    tags = {
      Name = "ecommerce-db-subnet"
    }
  
}

# create the database
resource "aws_db_instance" "ecommerceDB" {
    identifier = "ecommerce-db"
    engine = "postgres"
    engine_version = "15.13"
   
    # the instance class
    instance_class = "db.t3.micro" # free tier
    allocated_storage = 20  # GB

    #database name and master/user credential
    db_name = "ecommerceDB"
    username = "admin"
    password = random_password.db-password.result

    # network placement
    db_subnet_group_name = aws_db_subnet_group.db-subnet-group.name
    vpc_security_group_ids = [ aws_security_group.db-sg.id ]

    #backup configuration 
    backup_retention_period = 1 # it will retain backups for 7 days, daily snapshots and tansaction logs every 5 minutes
    backup_window = "03:00-04:00"  # it does daily backups at 3am to 4am everyday

    #Maintnance
    maintenance_window = "Mon:04:00-Mon:05:00"

    # security settings
    publicly_accessible = false  # the database is not accessible form the internet
    deletion_protection = false  # it is true by default, but we want to be able to destroy it from terraform cammand 
    skip_final_snapshot = true   # in dev we don't need to backup before detetion so we chose false

    tags = {
      Name="ecommerceDB"
    }
}
