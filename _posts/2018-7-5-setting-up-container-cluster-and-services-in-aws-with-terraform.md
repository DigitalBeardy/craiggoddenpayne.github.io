---
layout: post
title: Setting up a container cluster in aws with services using terraform
image: /assets/img/ecs-aws/cover.jpg
readtime: 4 minutes
---

I recently setup an ecs cluster in AWS, which allowed me to run containers on the cluster, rather than having to run individual ec2 instances per application.




Create a Dockerfile, such as
```
FROM docker.elastic.co/logstash/logstash:6.2.4

RUN logstash-plugin install logstash-input-beats
RUN logstash-plugin install logstash-output-http
RUN logstash-plugin install logstash-output-elasticsearch

RUN rm -f /usr/share/logstash/pipeline/logstash.conf
ADD pipeline/ /usr/share/logstash/pipeline/
ADD config/ /usr/share/logstash/config/

RUN cd ~ && curl -O http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz \
	&& tar -zxvf GeoLite2-City.tar.gz \
	&& cd GeoLite2-City_20180703 \	
	&& mv GeoLite2-City.mmdb /usr/share/logstash/bin/GeoLite2-City.mmdb	
```

Then you need to build your image, and push to your aws elastic container registry
```
#build.sh 
#!/bin/bash
set -e

BASE_REPO=XXXXXXXXXXXX.dkr.ecr.eu-west-2.amazonaws.com
IMAGE_NAME=my-image-name
VERSION=1.0.0

eval $(aws ecr get-login --region eu-west-2 --no-include-email)
sleep 1

docker build -t $IMAGE_NAME:$VERSION .
docker tag $IMAGE_NAME:$VERSION $BASE_REPO/$IMAGE_NAME:$VERSION
docker push $BASE_REPO/$IMAGE_NAME:$VERSION
```

Using terraform, you need to setup your elasticsearch cluster, and some ec2 to act as the container host

- variables

```
variable "aws_region" {
  default = "eu-west-2"
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["vpc.eu-west-2"]
  }
}

data "aws_subnet" "private" {
  count = "${length(data.aws_subnet_ids.private.ids)}"
  id    = "${data.aws_subnet_ids.private.ids[count.index]}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.tpl")}"

  vars {
    cluster_name = "${aws_ecs_cluster.container-cluster.name}"
  }
}
```

And create a user data file, to make sure the container host can register with ECS


- user_data.tpl
```
#!/bin/bash
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config 
echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config
echo 'vm.max_map_count = 262144' >> /etc/sysctl.conf
sysctl -p
```

```
#ECS
resource "aws_ecs_cluster" "my-container-cluster" {
  name = "my-container-cluster"
}

resource "aws_instance" "my-container-host" {
  ami           = "ami-3622cf51" #ecs optimized image
  instance_type = "t2.medium"

  vpc_security_group_ids = ["${aws_security_group.my-container-host.id}"]
  subnet_id              = "${data.aws_subnet_ids.private.ids[0]}"
  user_data              = "${data.template_file.user_data.rendered}"
  key_name               = "${terraform.workspace}-ec2-applications"
  iam_instance_profile   = "${aws_iam_instance_profile.my-ecs-instance-profile.name}"

  tags {
    Name = "my-container-host"
  }
}

resource "aws_security_group" "my-container-host" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

Then start looking at creating your service to run on the container cluster

- ecs cluster

```
data "aws_ecs_task_definition" "logstash" {
  task_definition = "${aws_ecs_task_definition.logstash.family}"
}

resource "aws_ecs_task_definition" "logstash" {
  family = "logstash"

  container_definitions = <<DEFINITION
[
  {
    "name": "logstash",
    "image": "XXXXXXXXXXXX.dkr.ecr.eu-west-2.amazonaws.com/craig/imagename",
    "essential": true,
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
    ],
    "portMappings": [
       {
         "hostPort": 5044,
         "protocol": "tcp",
         "containerPort": 5044
       },
       {
         "hostPort": 9600,
         "protocol": "tcp",
         "containerPort": 9600
       }
    ],
    "memory": 256,
    "cpu": 10
  }
]
DEFINITION
}

resource "aws_ecs_service" "logstash" {
  name                = "logstash"
  cluster             = "${aws_ecs_cluster.my-container-cluster.id}"
  task_definition     = "${aws_ecs_task_definition.logstash.family}:${max("${aws_ecs_task_definition.logstash.revision}", "${data.aws_ecs_task_definition.logstash.revision}")}"
  desired_count       = 1
  scheduling_strategy = "DAEMON"
}

```

Then setup you roles and policy

- iam

```
resource "aws_iam_role" "acquisition-ecs-service-role" {
  name               = "acquisition-ecs-service-role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-service-policy.json}"
}

resource "aws_iam_role_policy_attachment" "acquisition-ecs-service-role-attachment" {
  role       = "${aws_iam_role.acquisition-ecs-service-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs-service-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs-instance-role" {
  name               = "ecs-instance-role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-instance-policy.json}"
}

data "aws_iam_policy_document" "ecs-instance-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = "${aws_iam_role.ecs-instance-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "ecs-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs-instance-role.id}"
}

```

Once you apply the config, and the ec2 container host becomes ready, you will see that the container gets started

