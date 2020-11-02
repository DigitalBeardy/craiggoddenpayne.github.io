---
layout: post
title: Using AWS App Mesh
image: /assets/img/app-mesh/cover.png
readtime: 5 minutes
---

AWS App Mesh is a managed version of Service Mesh that AWS provide. 
App Mesh is designed to be used purely for traffic management of services running in AWS. 

### What is Service Mesh?

A service mesh is a dedicated infrastructure layer that controls service-to-service communication over a network. 
It provides a method in which separate parts of an application can communicate with each other. 
Service meshes appear commonly in concert with cloud-based applications, containers and microservices.

### Proxy and Control Plane

The proxy sits between all service and manages and observes all traffic. The control plane translates intent to proxy config, and distributes the proxy config to the proxy servers

### What are the alternatives

Istio is one of the most popular in this group of technologies.
Istio is not limited to just traffic management, it focuses on other features such as security and observability.

### How is AppMesh used?

AWS AppMesh can be used with Fargate / ECS / EKS and EC2.

In order for your app to communicate with AppMesh, you need to sideload a proxy inside your pod. 
There are various technology choices which can be used with this proxy

- HTTP access logging
- Cloudwatch logging
- Cloudwatch metrics
- StatsD
- Prometheus
- X-Ray
- Other envoy tracing drivers
- Load balancing
- Weighted targets
- Service discovery (DNS and cloud map)
- Path based routing


### App Mesh Constructs

- Virtual Services

A Virtual Service is a representation in App Mesh of an actual service. 
When your application makes a call to a different microservice, this is what it will call out to.

- Virtual Nodes

A Virtual Node represents the combination of a deployment and a service. 
A Virtual Node requires a DNS endpoint mapping it to a deployment. 
The name of the Virtual Node also needs to match an environment variable in the Envoy proxy so that it can identify itself. 
There are several other things that you manage in the Virtual Node, such as which services it can reach.
 
- Virtual Router and Routes

The Virtual Router and Routes create the connections between the Virtual Services and Virtual Nodes. 
You attach one or more Virtual Routers to your Virtual Service and then configure the routes to point at one or more Virtual Nodes. 


### Comparisons with Istio

| AppMesh | Istio |
| Runs in a sidecar | Runs from within your container |
| Path based routing | Can route based on anything within the request |
| On or off access to a service within the mesh | Allows RBAC and ACL controls per service method within a service |
| Active health checks | Active health checks |
| Some recovery features | More advanced recovery features |
| Integrates with existing AWS services easily | Full logging and monitoring with dashboards |
| No support for TLS | TLS supported |

### Why would we want this?

By using AppMesh, we can offload communication management logic from application code and libraries into configurable infrastructure, because this decouples from the application, it means that it is no longer thr responsibility of a developer to maintain and patch when newer versions of the sdks are made available.

Reduce troubleshooting time required by having end-to-end visibility into service-level logs, metrics and traces across your application.

Manage all service to service traffic using one set of APIs regardless of how the services are implemented.

Minimises the inconcistencies between services and how they interact with each other, as you can roll out changes to all without requiring deployments of individual applications.

