---
layout: post
title: Looking for a good reverse proxy solution
image: /assets/img/reverse-proxy/setup.png
readtime: 10 minutes
--- 

I have recently been working on a project to find which reverse proxy is best to sit in front of many services. The idea being that within the proxy, we are able to redirect the traffic to another service, to allow easy migration from an on prem solution, over to a cloud solution.

The criteria that had to be met was:

- Ability to return content from a microservice as fast as possible.

- Ability to update it dynamically.

- Channel the content from where it is hosted without running through an existing stack, due to high latency.

- Handle load without any performance degradation. 

The amount of traffic that the site got was around:

- Peak: 400 page views per second

- Avg: 200 page views per second

(each of the page requests would take up to 100ms for the backend)

### Options that were investigated:

The following approaches were identified as potential options for evaluation:

- NGINX
- Envoy
- HAProxy

#### NGINX

NGINX is a web server which can also be used as a reverse proxy, load balancer, mail proxy and HTTP cache.
The configuration of NGINX can be spread across multiple files if needed (separation of concerns), and can also be reloaded without any downtime after a configuration change.

NGINX offer a paid enterprise version (NGINX plus) which has the ability to be able to dynamically update the route config for proxying via a web api on top of traditional configuration.

#### Envoy
Envoy is a high-performance open source edge and service proxy that makes the network transparent to applications.

#### HAProxy
HAProxy is free, open source software that provides a high availability load balancer and proxy server for TCP and HTTP-based applications that spreads requests across multiple servers.

### Performance Metrics

<amp-img src="/assets/img/reverse-proxy/setup.png"
  width="1000"
  height="1000"
  layout="responsive">
</amp-img>


Due to limitations within the test environments, it was impossible to connect to test versions of the services, so instead
I created a sample app which would return a status 200 after 100 milliseconds, so that I could simulate delay. 

I hosted 50 containers of this app within AWS, and hosted different amount of containers of each proxy.

Using a performance testing tool (JMETER), the performance was pushed as far as it could, from real peak load, until we reached the point the proxies started to fail.

The tests were run in phases:

- 15 seconds with a smallish set of requests (10 requests per second)

- 15 seconds with a small amount of requests (50 requests per second)

- 15 seconds with medium amount of requests (100 requests per second)

- 15 seconds with average amount of requests (162 requests per second)

- 15 seconds with more than average amount of requests (250 requests per second)

- 15 seconds with peak amount of requests (320 requests per second)

- 15 seconds with very high amount of requests (500 requests per second)

- 15 seconds with extreme amount of requests (1000 requests per second)

And the load will be applied in the following way:

<amp-img src="/assets/img/reverse-proxy/load.png"
  width="1000"
  height="400"
  layout="responsive">
</amp-img>


Results:

NGINX:
- 4 proxy servers

<amp-img src="/assets/img/reverse-proxy/nginx4.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

- 8 proxy servers

<amp-img src="/assets/img/reverse-proxy/nginx8.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

- 16 proxy servers

<amp-img src="/assets/img/reverse-proxy/nginx16.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

- 32 proxy servers

<amp-img src="/assets/img/reverse-proxy/nginx32.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>


HAProxy:

- 4 proxy servers

<amp-img src="/assets/img/reverse-proxy/haproxy4.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

- 8 proxy servers 

<amp-img src="/assets/img/reverse-proxy/haproxy8.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

- 16 proxy servers

<amp-img src="/assets/img/reverse-proxy/haproxy16.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

- 32 proxy servers

<amp-img src="/assets/img/reverse-proxy/haproxy32.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

An interpolated view of mean results, against the same user count:

HAProxy: 

4 containers

<amp-img src="/assets/img/reverse-proxy/response-haproxy-4.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

8 containers

<amp-img src="/assets/img/reverse-proxy/response-haproxy-8.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

16 containers

<amp-img src="/assets/img/reverse-proxy/response-haproxy-16.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

32 containers

<amp-img src="/assets/img/reverse-proxy/response-haproxy-32.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

NGINX: 

4 containers

<amp-img src="/assets/img/reverse-proxy/response-nginx-4.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

8 containers

<amp-img src="/assets/img/reverse-proxy/response-nginx-8.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

16 containers

<amp-img src="/assets/img/reverse-proxy/response-nginx-16.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

32 containers

<amp-img src="/assets/img/reverse-proxy/response-nginx-32.png"
  width="1000"
  height="500"
  layout="responsive">
</amp-img>

### Learnings

Both NGINX and HAProxy are similar in the amount of traffic they can handle.

NGINX seems to be more predictable under load, and seems to be able to respond better.

HAProxy seems to be slightly faster

Tweaking configuration of both proxies can close the gap in results - HAProxy would still be a bit faster and Nginx more stable.

We are able to scale horizontally more containers of the proxy to handle the load behind it if needed, to any scale.

Dynamic Config

Both HAProxy and NGINX support config reloading, i.e. update config then reload without interruption

Updating via the api is supported in the enterprise version

We could also perform a blue green deployment fairly easily if immutable infrastructure is needed


### Overall Pros and Cons
NGINX Pros:
Documentation very mature, and lots of examples of how to do many scenarios
Configuration is straight forward, and no real learning curve
Took 1/2 day to setup a proof of concept
Supports SSL directly
SSL Termination
Predictable when under extreme load
NGINX Cons:
Web api for dynamic creation only available in the enterprise edition
Primarily a web server, with additional functionality to work as a reverse proxy
No status page

Envoy Pros:
Web api for dynamic creation available out of the box
Envoy Cons:
Small amount of documentation, not many examples online.
Configuration is quite complex
Further testing has been abandoned due to long configuration time and lack of satisfactory results within that time
Took 1 & 1/2 days to setup a proof of concept due to complexity and lack of documentation
Not really fit for purpose in this use case.

HAProxy Pros:
Documentation very mature, and lots of examples of how to do many scenarios
Configuration is straight forward, and no real learning curve
Took 1/2 day to setup a proof of concept
More flexibility on health checks and failover conditions than NGINX
Detailed status page, to see active requests and servers status

HAProxy Cons:
Web api for dynamic creation only available in the enterprise edition
Primarily a load balancer, with additional functionality to work as a reverse proxy
Less predictable when under extreme load

# Overall Decision

Recommended Option - NGINX

The reason we recommend NGINX is because of:
Ease of use
Documentation
Performance
Predictability
There happened to be more experience within the team using NGINX than any other option.