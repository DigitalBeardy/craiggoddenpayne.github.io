---
layout: post
title: 'Passing keys to dockerbuild from build agent'
image: /assets/img/docker-build/docker-build.png
readtime: 3 minutes
tags: docker rsa
---

At ditto, we use a docker build agent, for building our docker images and pushing to our private docker repository. 

This works really well for us, but there are times where you might want to say pass an rsa key to the docker image, which you would want to hide away from other devs.

Here is an example of how we achieved this by proxying the build agent id_rsa from the build agent to the docker image.

## Situation:

- We have a dockerfile, which our agent wants to build.

- As part of the docker build, we want to run npm install.

- The node project references a package in github that is hosted privately.

## Thoughts:

In order for the docker build to pass, the docker image will need to be referencing the rsa key added to the github repo, to be able to pull the code from github. 

Luckiliy, the docker agent is already pulling from github, and already has access to an account, which can access the npm module.

## Process:

In our build agent, we update the command to pass its id_rsa and id_rsa.pub key to our dockerfile, as a build argument

```
docker build . -t $APP_NAME:$GO_PIPELINE_LABEL --build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)"
```

Then all we need to do is add the following to our dockerfile to pickup the arguments.

```
ARG ssh_prv_key
ARG ssh_pub_key

RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
    echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub

```

Works a charm!

<amp-img src="/assets/img/docker-build/rsa.png"
  width="998"
  height="542"
  layout="responsive">
</amp-img>
