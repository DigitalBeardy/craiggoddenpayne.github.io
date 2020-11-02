---
layout: post
title: Autoscaling Fargate tasks, outside of a load balancer
image: /assets/img/fargate-autoscale-no-lb/cover.png
readtime: 10 minutes
---

I recently worked on a platform that required scaling. In the end, we chose to look at alternative options for autoscaling, but this was the approach we attempted. It would work well with applications that can be killed without notice, which was not our case.


In the past I have always used load balancer in combination with ecs/fargate to be able to keep a cluster of instances scaled to how I want them, and this is very simple, as web applications can easily be drained. In the case of my scenario I used target tracking scaling policy to scale the amount of instances, based on the amount of CPU Utilisation.

Here is a bit of a write up on how I did this:


I created an app autoscaling target for my fargate service. The minimum capacity was set to 1, and the maximum capcity was set to 9.

```
resource "aws_appautoscaling_target" "scale_target" {
  service_namespace = "ecs"
  resource_id = "service/cluster-name/service-name"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity = "1"
  min_capacity = "9"
}
```

I then created an autoscaling policy, which would automatically scale up or down based on the average CPU utilisation (which I set to 30%)

```
resource "aws_appautoscaling_policy" "autoscale_up" {
  name = "application-scaling"
  service_namespace = "${aws_appautoscaling_target.scale_target.service_namespace}"
  resource_id = "${aws_appautoscaling_target.scale_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.scale_target.scalable_dimension}"
  policy_type = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    customized_metric_specification {
      metric_name = "CPUUtilization"
      namespace = "AWS/ECS"
      statistic = "Average"
      dimensions {
        name = "ClusterName"
        value = "${data.terraform_remote_state.ecs_cluster.cluster_name}"
      },
      dimensions {
        name = "ServiceName"
        value = "${aws_ecs_service.ecs_service.name}"
      }
    }

    scale_in_cooldown = 30
    scale_out_cooldown = 30
    target_value = 30.0
  }
}
```