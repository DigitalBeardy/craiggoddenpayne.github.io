---
layout: post
title: Load Balancers in AWS
image: /assets/img/load-balancers/cover.png
readtime: 11 minutes
---

There are two PAAS load balancer offerings within AWS. The classic load balancer and the application load balancer.

In the past, the classic load balancer was called the elastic load balancer, but now the term elastic load balancer refers to the offerings for AWS load balancers.

The load balancers within AWS are region wide, i.e they will span across multiple availability zones within a single region, and they can be used for internal or external traffic.

### Classic load balancer

It works on layer 4 and layer 7 traffic, so can route traffic at a lower level of the TCP stack. You can use SSL termination with the classic load balancer, although not necessary. Without SSL termination, you are delegating this responsibility to the compute layer below, which is more secure, but will require more processing within the compute layer. Sticky sessions are supported with the classic load balancer, but there are better solutions out there for sticky sessions.

EC2 health checks and cloudwatch monitoring is supported in the classic load balancer, and it also integrated well with Route53. You cannot assign an elastic IP to a load balancer, but it works just fine with a dns name, but from a certificate point of view, multiple certs are required for multiple domains, unless you specify a wildcard

For security and analysis purposes you can also integrate with cloud trail, and it supports Ports 25 SMTP Ports 80/443 http(s) and any port between 1024-65535. You can use IPv4 or IPv2 and domain apex is also supported.

### Application load balancer

It works on layer 7 traffic only, but does this better than the classic load balancer, as you can route not just on path, but also content. It also has support for containers as well as just EC2, and it integrates really well with ECS.

The performance for real time streaming is a thing within the application load balancer, as it is more performant than the classic load balancer. It also has a lower hourly rate because you can route based on path and port, meaning you can provision less load balancers.

Application load balancers depend on "listeners". Listeners define the port and protocol, and you can have up to 10 listeners per load balancer. The routing rules are defined by the listener.

Listeners talk to target groups, so you also have to to define a target group(s). Target groups can be made up of EC2 or Containers, but not both. Target groups are region wide rather than availability zone wide, and can be associated with auto scaling groups if needed.

<amp-img src="/assets/img/load-balancers/example.png"
  width="596"
  height="441"
  layout="responsive">
</amp-img>

### Comparison Summary

- Classic load balancer supports http, https, tcp and ssl, whereas the Application load balancer only supports http and https.

- Classic load balancer supports health checks, so does the the Application load balancer, but supports more features.

- Classic load balancer supports cloudwatch, so does the Application load balancer, but supports a more more features.

On top of this, the following features are only supported in the Application load balancer:

- Path based routing
- Container support
- Websockets
- HTTP/2

