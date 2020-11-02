---
layout: post
title: Why switch to a more modern ci/cd system?
image: /assets/img/gitlab-jenkins/cover.jpg
readtime: 5 minutes
---

I've recently been working a lot with Gitlab, and though it would be useful to explain the pros and cons offered
a traditional ci/cd system, such as Jenkins against one of the more modern integrated systems such as GitLab CI.


### Jenkins / Team City / GoCD etc.

I'll mention Jenkins as it is the system I have had most experience with recently.

Jenkins is an extendable open source continuous integration server. 
Jenkins is one of the leading open-source CI servers.
Jenkins is open source and is self hosted.
Jenkins uses plugins to support building and testing virtually any type of project.

| Jenkins Pros| Jenkins Cons |
| Self hosted, meaning full control over workspaces | Big overhead for small projects, as the setup of a pipeline is quite involved |
| Easy management of credentials | This can be even more so complicated depending on plugin integrations |
| Big plugin library to suit most projects | You have to have a new pipeline for every environment, and workflow view is pulled in using another plugin |
| | Jenkins does not have a very good security record |
| | You need to spend additional time setting up servers, and time maintaining servers |


### GitlabCI / CircleCI etc.

I'll mention GitlabCI as it is the system I have had most experience with recently.

Gitlab is also open source, and can be self-hosted.
It's primary purpose is a git source control central repository.
On top of this, it also offers code reviews, issue tracking, activity feeds and wikis. 


| Gitlab Pros | Gitlab Cons |
|---|---|
| Very good Docker integration, leading to an endless amount of easy to use configurations for building / deploying projects. | Artifacts have to be defined and uploaded/downloaded for every job |
| Easy to setup and visualise workflows | Testing the merged state of a branch is not possible before actual merge is done | 
| Parallel job execution within stages of a pipeline | |
| It is possible to setup a flow within your pipeline, like a DAG (directed acyclic graph) | |
| Easy to extend and maintain pipelines | |
| Integrates with hooks outside the norm on git, such as on creation of a merge request | |
| Endlessly scalable due to concurrent runners | |


### Result 

It seems overwhelmingly obvious that GitLab is a clear winner here. The ability to be able to do pretty much anything without
the restrictions put in place by a more traditional ci system, really make it a no brainer. I think one of my favourite things 
about gitlab, is that the yaml file which describes deployment is contained within the source code, which makes it very simple to
make changes to it, and it be versioned, the same way that the rest of the code is.

Here's a link to a post on hackernoon which has a pretty good tutorial on how to setup a gitlab-ci.yaml

https://hackernoon.com/configuring-gitlab-ci-yml-150a98e9765d