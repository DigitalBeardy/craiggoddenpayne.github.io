---
layout: post
title: Setting up continuous integration within Gitlab
image: /assets/img/
readtime: 5 minutes
---

GitLab CI/CD allows you to apply continuous methods (Continuous Integration, Delivery, and Deployment) to software without the need for third-party applications or integrations.


To enable CI/CD within Gitlab, you add a .gitlab-ci.yml file to the root directory of your repository.
Once you configure at last one Gitlab Runner, then each commit or push will trigger your CI pipeline.


The steps needed to have a working CI can be summed up to:
A working GitLab instance of version 8.0+
Add .gitlab-ci.yml to the root directory of your repository
Configure a Runner

The .gitlab-ci.yml file is where you configure what CI does with your project. It lives in the root of your repository.

On any push to your repository, GitLab will look for the .gitlab-ci.yml file and start jobs on Runners according to the contents of the file, for that commit.

Example:

```
image: "ruby:2.5"

before_script:
  - apt-get update -qq && apt-get install -y -qq sqlite3 libsqlite3-dev nodejs
  - ruby -v
  - which ruby
  - gem install bundler --no-document
  - bundle install --jobs $(nproc)  "${FLAGS[@]}"

rspec:
  script:
    - bundle exec rspec

rubocop:
  script:
    - bundle exec rubocop
```

Configuring a Runner
In GitLab, Runners run the jobs that you define in .gitlab-ci.yml. A Runner can be a virtual machine, a VPS, a bare-metal machine, a docker container or even a cluster of containers. GitLab and the Runners communicate through an API, so the only requirement is that the Runner’s machine has network access to the GitLab server.

A Runner can be specific to a certain project or serve multiple projects in GitLab. If it serves all projects it’s called a Shared Runner.