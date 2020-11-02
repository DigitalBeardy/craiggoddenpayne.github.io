---
layout: post
title: '#DevOps and the evolution from Developer to multi skilled Engineer'
image: /assets/img/devops/devops.png
readtime: 18 minutes
tags: devops, iaas, terraform, aws, engineer, 
---

*TLDR - DevOps is awesome, DevOps is not scary, and using the right tools and patterns will allow you to easily transition from Software Developer to Software Engineer and keep ahead of the trend*

*First its worth having a look at the definiton of what DevOps is,*  bear in mind DevOps is a term that still does not have a solid definition, and a lot of people get confused as to what it is:

DevOps is a term emerging from the collision of two major related trends. The first was also called “agile infrastructure” or “agile operations”; it sprang from applying Agile and Lean approaches to operations work. The second is a much expanded understanding of the value of collaboration between development and operations staff throughout all stages of the development lifecycle when creating and operating a service, and how important operations has become in our increasingly service-oriented world.

<amp-img src="/assets/img/devops/multiskilled.png"
  width="1310"
  height="1076"
  layout="responsive">
</amp-img>

By applying DevOps to your current role, you create the ability for your company to deliver applications with high velocity, by using tools, practices and cultural philosophies to improve and evolve faster than tradition software practices that rely on other siloed teams.


As an engineer, you should be able to work across the full application lifecycle, including (but not limited to) development, testing, deployment and infrastructure, even sometimes quality assurance and infosec. If you make as much of the process  automated as possible, it prevents leaving an individual holding all the knowledge, and also helps prevents bottlenecks between teams waiting on other teams.

Theres a wide school of thought online that its the next evolution of software engineers.

<amp-img src="/assets/img/devops/devopscycle.png"
  width="1000"
  height="567"
  layout="responsive">
</amp-img>


## Is DevOps adoption growing?

DevOps adoption is certainly growing! The current demand in the market is rapidly increasing. This is primarily because employing DevOps has resulted in great success for companies all around the world for the following reasons:

- Shorter Development Cycles, Faster Innovation
- Reduced Deployment Failures, Rollbacks, and Time to Recover
- Improved Communication and Collaboration
- Reduced Costs and IT Headcount

One thing to remember though, is that the process of becoming an expert DevOps engineer is highly complex. You have to be well prepared and organized, and expertise only comes with extreme hard work and by having a good research background.

<amp-img src="/assets/img/devops/devopstrends.png"
  width="1350"
  height="720"
  layout="responsive">
</amp-img>

# How to make the transition easier / where to start?

## Normalising the tech stack

To reduce complexity, it is a good idea to normalise the technology stack. This will reduce the scope that engineers will need to know, although this shouldn't be normalised to the point where it limits tech choices.

### Reusable deployment patterns

For developers who traditionaly have never worked on deployments, or delivering software, DevOps can be daunting. Its important to create reusable deployment patterns, so the steep learning curve isnt so steep. 

At ditto music, one of the first patterns we worked on, was to create a reusable deployment pattern. We wanted to automate the provisioning of the instance, and have a platform where the code can just be deployed. There are many options for this, at the time we built the pattern we evaluated and decided on AWS Elastic Container Service.

Our deployment pattern took a built artifact such as a dotnet dll or node project, and we build a docker image, pushed to our own Elastic Container Repository and used a templated service and task to be able to run the 'WebApp' in a predicatable and similar way across technology stacks. We use it for long running services, rest services, graphql, websites etc.

Because of the way ECS works, it was very simple to build secure permissions and apply this across the whole infra. Anything that needs more than just the basics, could apply it manually. Terraform modules really helped with this.

<amp-img src="/assets/img/devops/nodes.png"
  width="491"
  height="181"
  layout="responsive">
</amp-img>


### Always improving the tech stack

Just because you have a great stack, doesn't mean you should continue to use it until the end of time! 

There are so many great things coming out all the time, for example at ditto music we use ECS, but that is because at the time fargate was not available in London. Now it is, we are evaluating moving our ECS web apps over to Fargate, as this serverless option will have many benefits with reducing complexity of deployments, cheaper to run and more scalable.



### Reusable testing patterns

Theres many testing trends out there, but having at least the basics will help reduce complexity, at ditto we use test driven development, unit tests, acceptance criteria to drive the design and automation testing. UI testing using tools like Cypress.js and end to end integration tests for apis and databases really help. Even simple things like integrating coverage reports into your build process will help to keep the code standard high, as well as testing the actual application. 

Monitoring tools that not only show the current trend of how an application is performing, but also alerting. At ditto we use a combination of Elasticsearch, AWS cloudwatch logs, and a custom logging service, will all alerts that are deemed important notifying us using slack.

<amp-img src="/assets/img/devops/unittest.png"
  width="1140"
  height="726"
  layout="responsive">
</amp-img>


## Maintainability and openness

### Logging

Logging is so important to make sure you can quickly work out why an application is malfunctioning. Its not only important to log things, its important to know when to act upon it. At ditto we use a combination of tools from Cloudwatch alarms, to elastalert to make sure that we are notified about problematic applications before the customer knows theres a problem.

<amp-img src="/assets/img/devops/slackalert.png"
  width="1300"
  height="846"
  layout="responsive">
</amp-img>

If you can streamline your logging process into one or a few very similar systems, it makes diagnosing issues easier. I'm not a massive fan of cloudwatch logging, but its ok as a minimum. Being able to search over massive amounts of logs is much better using a tool like Elasticsearch.

### Metrics gathering

Its not just gathering logs which is important, you can also gather metrics. Whether its how a user is interacting with you application, or whether a certain resource you rely on is about to run out. There are means and ways to tie all this information and be notified way before theres a problem

<amp-img src="/assets/img/devops/trends.png"
  width="958"
  height="750"
  layout="responsive">
</amp-img>

### Sharing knowledge, and source code

There are caveats to this, of course you would only ever want to share code, where its safe to do so, for example Team 1 might have a member who has just deployed a new application that has created a pattern that Team 2 would benefit from using. The benefit of sharing this code and process is massively helpful. It's never a good idea for one person to dictate all the decisions, processes will never evolve. Brown bags and information sharing sessions really help with this too!

# Reliability 

### CI/CD

Having a solid CI/CD process is one of the most important things. At ditto and places I've worked before, we deliver to production many times a day. Gone are the days where there is a release every 6 weeks. If you want to act fast and make quick business decisions, you need to be able to release fast.

There seems to be a growing trend of containerised CI/CD systems that are awesome, which can spin up as many agents as needed. At ditto we went for GoCD by thoughtworks, and built it in a containerised style. I guess its whatever fits the need

<amp-img src="/assets/img/devops/cicd2.png"
  width="1036"
  height="224"
  layout="responsive">
</amp-img>

### Test infrastructure changes before deploying to production

To make sure that you keep your application running as close to 100%, always test your infrastructure changes before a deployment to production. At ditto music, we utilise terraform, and will always perform a terraform plan before an apply.

This will outline what is about to change before it is applied.

Another thing that helps with this is blue/green deployments. This is so straightforward in tech like Elastic Container Service, as you can easily spin up the new instance of a container almost instantly and only switch the load balancer to point to the new instance once it passes all the smoke tests.

<amp-img src="/assets/img/devops/statuscodes.png"
  width="1620"
  height="1312"
  layout="responsive">
</amp-img>

### Automate infrastructure delivery

Use tools like terraform (my personal favourite), which enables you to safely and predictably create, change, and improve infrastructure. It is an open source tool that codifies APIs into declarative configuration files that can be shared amongst team members, treated as code, edited, reviewed, and versioned. 


<amp-img src="/assets/img/devops/terraform.png"
  width="520"
  height="313"
  layout="responsive">
</amp-img>


### Automate security policy configuration

Where possible apply security policies at the highest level possible and only allow the smallest amount of changes to security between apps. An example of this is to apply the hardest possible rules, and only allow very specific changes at the IAM layer. At ditto, we use terraform modules to allow us to template our applications, and only add bespoke permissions where needed, limited to the scope of what is needed.

e.g. if an application needs to call SQS, then we add a permission to the single application, allowing only for that single application to call a single SQS queue.

# Conclusion

In conclusion, DevOps is forever despite the cries of DevOps demise, the core principles that DevOps have will live on as long as businesses require software to succeed in a fast-paced, rapidly changing technological landscape. In a few years, the name may fade away in favour of a new buzzword, but the culture and the contributions of the DevOps community will live on.