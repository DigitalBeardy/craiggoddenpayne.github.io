---
layout: post
title: ECS AWS WebApps - A simple pattern for deploying anything quickly using terraform 
image: /assets/img/ecs-aws/cover.jpg
readtime: 6 minutes
tags: AWS ECS Docker Terraform
---

One of the best things I like about infrastructure as code, and terraform in particular, is the ability to quickly, and securely deploying something, based on a pattern that you know works.

This blog post looks into a pattern we use at ditto music, to deploy a services, apis, ci build agents, websites and basically anything that can be run on a docker container. This post uses ECS as the example technology, but it could be as easy to swap out to use fargate, since it's now available in the eu-west-2 London region. 

<amp-img src="/assets/img/ecs-webapps/architecture.png"
  width="785"
  height="914"
  layout="responsive">
</amp-img>

Above is a high level overview of what we've deemed a ecs web app. As you can see, we have two Application Load Balancers, one associated with *.dittomusic.com and one associated with internal.dittomusic.com. Security rules have been setup, so one will only allow traffic from inside the VPC, and the other from the outside web. 

We have multiple subnets within our VPC which have specific rules, but the ECS applications are deployed within our "private" subnet, so they are not accessible from the outside. 


One of my favourite things about terraform is modules. It allows you to pretty much template a load of other resources, so you can deploy a very predictable set of things.


Here is an example of what we use

```
module "ecs-web-app" {
  source                  = "git::git@github.com:DittoMusic/SCRUBBED"
  app_name                = "${var.app_name}"
  region                  = "${var.region}"
  application_version     = "${var.application_version}"
  task_memory             = "${var.memory}"
  container_port          = "${var.container_port}"
  attach_to_load_balancer = "internal"
  lb_pattern              = "/reporting*"
  lb_rule_number          = 6
  desired_count           = 2
  health_check_period     = 30
}
```

This describes a single web app. In this case, an example is a reporting app, which could be say a node app. We inject the properties in, such as the region we want to deploy to, which load balancer to attach to (public, internal or none at all), the amount of instances needed, when to do health checks etc.

#### ECS service definition

```
resource "aws_ecs_service" "ecs-service-with-loadbalancer" {
  count = "${var.attach_to_load_balancer == "public" ? 1 : var.attach_to_load_balancer == "internal" ? 1 : 0}"
  name                              = "${var.app_name}"
  cluster                           = "${data.aws_ecs_cluster.app-container-host.id}"
  task_definition                   = "${aws_ecs_task_definition.definition.arn}"
  scheduling_strategy               = "REPLICA"
  desired_count                     = "${var.desired_count}"
  health_check_grace_period_seconds = "${var.health_check_period}"
  iam_role                          = "${aws_iam_role.api.name}"

  ordered_placement_strategy {
    type  = "spread"
    field = "host"
  }

  load_balancer {
    container_name   = "${var.app_name}"
    container_port   = "${var.container_port}"
    target_group_arn = "${aws_lb_target_group.api.arn}"
  }
}


resource "aws_ecs_service" "ecs-service-without-loadbalancer" {
  count = "${var.attach_to_load_balancer == "public" ? 1 : var.attach_to_load_balancer == "internal" ? 0 : 1}"
  name                              = "${var.app_name}"
  cluster                           = "${data.aws_ecs_cluster.app-container-host.id}"
  task_definition                   = "${aws_ecs_task_definition.definition.arn}"
  scheduling_strategy               = "REPLICA"
  desired_count                     = "${var.desired_count}"
}

```

#### Below is the iam role definition. (I've removed the iam policy information for security reasons)

```
resource "aws_iam_role" "api" {
  name = "${var.app_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

output "iam-role-name" {
  value = "${aws_iam_role.api.name}"
}
```

#### Load balancer setup (Some information removed for security reasons)

```
data "aws_lb" "internal" {
  name = "ditto-website-alb-internal"
}

data "aws_alb_listener" "internal" {
  load_balancer_arn = "${data.aws_lb.internal.arn}"
  port              = 443
}

data "aws_lb" "public" {
  name = "ditto-website-alb"
}

data "aws_alb_listener" "public" {
  load_balancer_arn = "${data.aws_lb.public.arn}"
  port              = 443
}

resource "aws_lb_target_group" "api" {
  count = "${var.attach_to_load_balancer == "public" ? 1 : var.attach_to_load_balancer == "internal" ? 1 : 0}"
  protocol   = "HTTP"
  vpc_id     = "${data.aws_vpc.vpc.id}"
  name       = "${var.app_name}"
  slow_start = 0
}

resource "aws_lb_listener_rule" "api" {
  count = "${var.attach_to_load_balancer == "public" ? 1 : var.attach_to_load_balancer == "internal" ? 1 : 0}" 
  listener_arn = "${var.attach_to_load_balancer == "public" ? data.aws_alb_listener.public.arn : data.aws_alb_listener.internal.arn}"
  priority     = "${var.lb_rule_number}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.api.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["${var.lb_pattern}"]
  }
}
```

#### Task definition 

```
resource "aws_ecs_task_definition" "definition" {
  family             = "${var.app_name}"
  network_mode       = "bridge"
  task_role_arn      = "${aws_iam_role.api.arn}"
  execution_role_arn = "${aws_iam_role.api.arn}"

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.app_name}",
    "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-2.amazonaws.com/${var.app_name}:${var.application_version}",
    "essential": true,
    "privileged": true,
    "memoryReservation": ${var.task_memory},
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
          "name": "ApplicationVersion",
          "value": "${var.application_version}"
      }
    ],
    "requiresAttributes": [
        {
        "value": null,
        "name": "com.amazonaws.ecs.capability.ecr-auth",
        "targetId": null,
        "targetType": null
        },
        {
        "value": null,
        "name": "com.amazonaws.ecs.capability.task-iam-role",
        "targetId": null,
        "targetType": null
        },
        {
        "value": null,
        "name": "com.amazonaws.ecs.capability.docker-remote-api.1.19",
        "targetId": null,
        "targetType": null
        }
    ]
  }
]
DEFINITION
}

```

#### and finally the variables

```
variable "app_name" {}
variable "region" {}
variable "application_version" {}
variable "task_memory" {}
variable "container_port" {}
variable "desired_count" {}
variable "health_check_period" {
  default = 30
}

variable "attach_to_load_balancer" {
  description = "Values should be `internal` `public` or `none`"
  default = "none"
}
variable "lb_rule_number" {
  description = "The load balancer rule number (priority)"
  default = 0
}
variable "lb_pattern" {
  description = "The load balancer path pattern"
  default = ""
}

data "aws_vpc" "vpc" {
  tags {
    Name = "vpc.eu-west-2"
  }
}
data "aws_ecs_cluster" "app-container-host" {
  cluster_name = "app-container-host"
}
data "aws_caller_identity" "current" {}

```


Now all the infrastructure is sorted, its just a case of the docker file, so that we can actually run our app on the infrastructure:

```
FROM microsoft/dotnet:2.1-sdk

WORKDIR /app
COPY . . 

ENV Environment="qa"
ENV AwsRegion="eu-west-2"
ENV ApplicationVersion="{APPLICATION_VERSION}"
ENTRYPOINT ["dotnet", "my-application.dll"]
```

<amp-img src="/assets/img/ecs-webapps/infrastructure.png"
  width="1498"
  height="1332"
  layout="responsive">
</amp-img>

