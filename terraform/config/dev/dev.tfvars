project_name           = "scb"
environment            = "dev"
region                 = "ap-southeast-1"
account_id             = "872132143780"


vpc_cidr = "172.25.0.0/16"

private_subnets  = ["172.25.1.0/24", "172.25.2.0/24"]
public_subnets   = ["172.25.3.0/24", "172.25.4.0/24"]
database_subnets = ["172.25.5.0/24", "172.25.6.0/24"]

vpc_azs         = ["ap-southeast-1a", "ap-southeast-1b"]

s3_config = {
  log_bucket_name                   = "log"
  web_bucket_name                   = "web"
  app_bucket_name                   = "app"
}

load_balancer = {
  services = {
    app = {
      elb_type    = "application"
      is_internal = "true"
      port        = 80
      public_port = 80
      protocol    = "HTTP"
    },
    web = {
      elb_type    = "application"
      is_internal = "false"
      port        = 80
      public_port = 80
      protocol    = "HTTP"
    }
  }
}

autoscaling_group = {
  replication_instance_class                 = "t2.micro"
  replication_instance_class_validation_only = "t2.micro"

  services = {
    app = {
      app_desired_capacity = "1"
      app_max_size         = "1"
      app_min_size         = "1"
      app_base_ami         = "ami-0c38b837cd80f13bb"
      instance_type        = "t2.micro"
      volume_size          = "10"
    },
    web = {
      app_desired_capacity = "1"
      app_max_size         = "1"
      app_min_size         = "1"
      app_base_ami         = "ami-0c38b837cd80f13bb"
      instance_type        = "t2.micro"
      volume_size          = "10"
    }
  }
}