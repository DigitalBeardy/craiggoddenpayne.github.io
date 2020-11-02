---
layout: post
title: Blue Green deployments, utilising Terraform and AWS ECS
image: /assets/img/bluegreen/cover.png
readtime: 10 minutes
tags: blue green deployment terraform aws ecs
---

### What is a blue green deployment?

Blue-green deployment is a technique that reduces downtime and risk by running two identical production environments called Blue and Green.

At any time, only one of the environments is live, with the live environment serving all production traffic. 

As you prepare a new version of your software, deployment and the final stage of testing takes place in the environment that is not live: in this example, Green. Once you have deployed and fully tested the software in Green, you switch the router so all incoming requests now go to Green instead of Blue. Green is now live, and Blue is idle.

This technique can eliminate downtime due to app deployment. In addition, blue-green deployment reduces risk: if something unexpected happens with your new version on Green, you can immediately roll back to the last version by switching back to Blue

<amp-img src="/assets/img/bluegreen/bluegreenrouter.png"
  width="1464"
  height="566"
  layout="responsive">
</amp-img>

### Blue Green at Ditto

At Ditto, we perform blue green deployments by utilising ECS. You could just as easily do this with fargate, but the following information is how we set this up using ECS.

The majority of deployments follow the same pattern (using the same template).

Here is an overview of the deployment pipeline we use, to get code from source to production.

<amp-img src="/assets/img/bluegreen/pipeline.png"
  width="1326"
  height="374"
  layout="responsive">
</amp-img>

#### Build Stage (build-ecs-webapp template)

- Build artifacts
- Run unit tests
- Run integration tests
- Coverage reports
- Store artifacts in S3

#### QA Stage (publish-ecs-webapp template)

- Pull artifacts from S3
- Build docker image
- Upload docker image to repository
- Review infrastructure changes
- Apply infrastructure changes (This causes a blue green deployment to the environment) 

#### Prod Stage
- Pull artifacts from S3
- Build docker image
- Upload docker image to repository
- Review infrastructure changes
- Apply infrastructure changes (This causes a blue green deployment to the environment)

The deployment to the environment is completely automated, which means we can move from development to production in a matter of minutes if needed. We write all our code on mainline and use feature toggles where necessary. This keeps the codebase clean, and always ready to deploy

<amp-img src="/assets/img/bluegreen/docker.png"
  width="660"
  height="330"
  layout="responsive">
</amp-img>

### A bit more about our templates

#### Build-ECS-WebApp

The following steps take place:

- Fetch - which is triggered from a commit to git. The code is pulled from github onto the agent
- Build-Build - auto triggered and ran in parallel, which runs a script called build.sh
- Build-Test - auto triggered and ran in parallel, which runs a script called test.sh
- Build-Test-Report - auto triggered and ran in parallel, which runs a script called test-report.sh 
- Build-Terraform-Build - auto triggered, which takes terraform configuration files and zips them up
- Upload - which is auto triggered, uploads the above build artifacts, and stores them in S3, alongside the current version

e.g. 

s3://gocd-build-artifacts/my-application/1.230.1/deployable.zip

s3://gocd-build-artifacts/my-application/1.230.1/terraform.zip

#### Publish-ECS-WebApp 

The following steps take place:

- Fetch-S3 - auto triggered, pulls the version of the code that was built, from S3
- Docker-BuildTagPush - auto triggered, builds the docker image included in the codebase, tags it with the version and pushes to our private repo in AWS
- Post-Docker - auto triggered, used in some builds to allow running code after the docker publish
- Terraform Review - auto triggered, plans the updates to infrastructure
- Terraform Apply - manually triggered after someone reviewing the infrastructure plan. This will apply the changes to infrastructure, which in turn applies the new version of the ECS task, which causes a blue green deployment.
- The same template would be then chained on from the previous environment, allowing us to force a pipeline like Build → QA → Prod

### How does this work in terraform then?

Example using our terraform module:

```
module "ecs-web-app" {
  source                  = "git::git@github.com:**********/terraform-modules.git//aws-ecs-ec2?ref=v1.0.37"
  app_name                = "${var.app_name}"
  region                  = "${var.region}"
  application_version     = "${var.application_version}"
  task_memory             = "${var.memory}"
  container_port          = "${var.container_port}"
  attach_to_load_balancer = "internal"
  lb_pattern              = "/path*"
  lb_rule_number          = 6
  desired_count           = 2
  health_check_period     = 30
}

```

In actual terraform, we create something similar to the following:

```
resource "aws_ecs_service" "ecs-service-with-loadbalancer" {
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

```

```
data "aws_lb" "internal" {
  name = "ditto-website-alb-internal"
}

data "aws_alb_listener" "internal" {
  load_balancer_arn = "${data.aws_lb.internal.arn}"
  port              = 443
}

resource "aws_lb_target_group" "api" {
  protocol   = "HTTP"
  vpc_id     = "${data.aws_vpc.vpc.id}"
  name       = "${var.app_name}"
  port       = 80
  slow_start = 0
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = "data.aws_alb_listener.public.arn"
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

### How this looks in AWS

Container images are maintained in ECR, so we can roll back to any version if needed.

Deployment is triggered, tasks are marked as inactive in AWS

<amp-img src="/assets/img/bluegreen/2.png"
  width="2292"
  height="438"
  layout="responsive">
</amp-img>

The new task is started, and enters a pending state

<amp-img src="/assets/img/bluegreen/3.png"
  width="2300"
  height="562"
  layout="responsive">
</amp-img>

The new task starts successfully, and a health check is performed from the load balancer to container:port

<amp-img src="/assets/img/bluegreen/4.png"
  width="2294"
  height="562"
  layout="responsive">
</amp-img>

After 30 seconds or so, the old version of the containers are taken out of the cluster

<amp-img src="/assets/img/bluegreen/5.png"
  width="2298"
  height="430"
  layout="responsive">
</amp-img>

Here is an example of the log, which shows the blue green deployment.

<amp-img src="/assets/img/bluegreen/6.png"
  width="2270"
  height="546"
  layout="responsive">
</amp-img>