---
layout: post
title: Setting up an alb as an alternative to nginx, using terraform
image: /assets/img/alb/cover.jpg
readtime: 8 minutes
tags: terraform, nginx, alb, aws
---

Setting up NGINX or Apache can be a pain. I've been working with AWS Application Load Balancer recently, and setting up routing is fairly straightforward, and in my opinion, if more descriptive, easier to use and maintain.


### Here's the setup I used:


Create an application load balancer, something like:

```
resource "aws_lb" "my-website" {
  name               = "my-website-alb"
  load_balancer_type = "application"x
  internal           = false
  idle_timeout       = 400
  subnets = [
    "${data.aws_subnet_ids.public.ids[0]}", 
    "${data.aws_subnet_ids.public.ids[1]}"
  ]
  
  security_groups = ["${aws_security_group.my-website-public.id}"]
  enable_http2 = true
  
  tags {
    Name = "my-website-alb"
  }
  
}
```

You'll then need to add a listener for http, and https traffic:

```
resource "aws_lb_listener" "my_website_https" {
  load_balancer_arn = "${aws_lb.my-website.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_acm_certificate.cert.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.my_website_http.arn}"
  }
}

resource "aws_lb_listener" "my_website_http" {
  load_balancer_arn = "${aws_lb.my-website.arn}"
  
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    target_group_arn = "${aws_lb_target_group.my_website_http.arn}"
    
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
      host = "#{host}"
      path = "/#{path}"
      query = "#{query}"
    }
  }
}
```

You'll need to setup a target group to point to a specific instance as the default route

```
resource "aws_lb_target_group" "my_website_http" {
  port = 80
  protocol = "HTTP"
  vpc_id = "${data.aws_vpc.vpc.id}"
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "my_website_instance" {
  target_group_arn = "${aws_lb_target_group.dmy_website_http.arn}"
  target_id = "${data.aws_instance.my-website.id}"
}
```

The if you want to also target the apex (naked domain) you'll want to do something like this:

```
resource "aws_lb_listener_rule" "apex_redirect_https" {
  listener_arn = "${aws_lb_listener.my_website_https.arn}"
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.my_website_http.arn}"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
      host = "www.${var.zone}"
      path = "/#{path}"
      query = "#{query}"
    }
  }

  condition {
    field  = "host-header"
    values = ["${var.zone}"]
  }
}

resource "aws_lb_listener_rule" "apex_redirect_http" {
  listener_arn = "${aws_lb_listener.my_website_http.arn}"
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.my_website_http.arn}"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
      host = "www.${var.zone}"
      path = "/#{path}"
      query = "#{query}"
    }
  }

  condition {
    field  = "host-header"
    values = ["${var.zone}"]
  }
}
```

If you are targeting HTTPS, you will need to setup certificates:

```
resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.zone}"
  validation_method = "DNS"
  subject_alternative_names = ["${terraform.workspace == "qa" ? "*.qa.mysite.com" : "*.mysite.com"}"]
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}
```

That's it!
