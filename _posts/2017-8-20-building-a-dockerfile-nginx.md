---
layout: post
title: Building a docker container - nginx
image: /assets/img/building-a-docker-container-nginx/nginx-docker.jpg
readtime: 14 minutes
---

Recently I was working with docker, and I found it a bit painful. I think I just jumped straight in without any real knowledge, but after some time to reflect I've been looking more at docker, dockerfile in general, as a way to build a custom docker image.

The offical documentation states:

- A Dockerfile is a text document that contains all the commands a user could call on the command line to assemble an image. Using docker build users can create an automated build that executes several command-line instructions in succession.

This is perfect, if you can't find a pre built image you want or (in the case I was looking) needing to build a specific version of Nginx, to match the current production box, along with a few other pieces of software, so I could in effect run everything locally.

Since I don't want to give away which versions / software are installed on the production box at work, the example I am going to use is similar, but not like for like. I'm also aware you can get the nginx image from dockerhub, but I wanted to show an example of how you would build something from scratch.

First of all specify the base image that you want to use, I have chosen ubuntu and create the normal directory that you would use for nginx

```bash
FROM ubuntu
RUN mkdir /etc/nginx
WORKDIR /etc/nginx
```

Then I'm going to copy eveything from what I have stored in source control (basically my config files for nginx).
```bash
COPY /Nginx/ ./
```

Then I'm going to update the system 

```bash
WORKDIR /var/home/
RUN apt-get update
RUN apt-get install -y --no-install-recommends apt-utils net-tools vim
RUN apt-get update
```

Then I'm going to add an entry for dockerhost, that will allow me to configure the proxy upstream to call a service on my machine (outside of docker) 
In order to do this though, I'll need to set the net mode to Host. e.g. docker run -u 0 -it -p 443:443 --net="host" craiggoddenpayne/nginx bash and add a host into my host file, such as 10.0.75.2	www.myaddress.com
```bash
EXPOSE 443
RUN echo $(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}') dockerhost >> /etc/hosts
RUN nginx start -c /etc/nginx/nginx.conf &
```

The full config looks like as follows:

```bash
FROM ubuntu
RUN mkdir /etc/nginx
WORKDIR /etc/nginx
COPY /Nginx/ ./
WORKDIR /var/home/
RUN apt-get update
RUN apt-get install -y --no-install-recommends apt-utils net-tools vim
RUN apt-get update
EXPOSE 443
RUN echo $(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}') dockerhost >> /etc/hosts
RUN nginx start -c /etc/nginx/nginx.conf &
```

Once you have something similar to the above, creating an image is dead simple.

run the command  
```bash
docker build -f /path/to/a/Dockerfile -t craiggoddenpayne/nginx-pagespeed-beats .
```

which will output something similar to:


```bash
C:\temp>docker build -f dockerfile -t craiggoddenpayne/nginx-pagespeed-beats .
Sending build context to Docker daemon  590.8kB
Step 1/9 : FROM ubuntu
 ---> 747cb2d60bbe
Step 2/9 : RUN mkdir /etc/nginx
 ---> Using cache
 ---> 662c8d986177
Step 3/9 : WORKDIR /etc/nginx
 ---> Using cache
 ---> 7cf018620282
Step 4/9 : WORKDIR /var/home/
Removing intermediate container 91f1f2df6de2
 ---> 3795133574a3
Step 5/9 : RUN apt-get update
 ---> Running in 759cff5b4fc7
Get:1 http://security.ubuntu.com/ubuntu xenial-security InRelease [102 kB]
Get:2 http://archive.ubuntu.com/ubuntu xenial InRelease [247 kB]
Get:3 http://archive.ubuntu.com/ubuntu xenial-updates InRelease [102 kB]
Get:4 http://archive.ubuntu.com/ubuntu xenial-backports InRelease [102 kB]
Get:5 http://security.ubuntu.com/ubuntu xenial-security/universe Sources [72.8 kB]
Get:6 http://security.ubuntu.com/ubuntu xenial-security/main amd64 Packages [584 kB]
Get:7 http://archive.ubuntu.com/ubuntu xenial/universe Sources [9802 kB]
Get:8 http://security.ubuntu.com/ubuntu xenial-security/restricted amd64 Packages [12.7 kB]
Get:9 http://security.ubuntu.com/ubuntu xenial-security/universe amd64 Packages [403 kB]
Get:10 http://security.ubuntu.com/ubuntu xenial-security/multiverse amd64 Packages [3486 B]
Get:11 http://archive.ubuntu.com/ubuntu xenial/main amd64 Packages [1558 kB]
Get:12 http://archive.ubuntu.com/ubuntu xenial/restricted amd64 Packages [14.1 kB]
Get:13 http://archive.ubuntu.com/ubuntu xenial/universe amd64 Packages [9827 kB]
Get:14 http://archive.ubuntu.com/ubuntu xenial/multiverse amd64 Packages [176 kB]
Get:15 http://archive.ubuntu.com/ubuntu xenial-updates/universe Sources [240 kB]
Get:16 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 Packages [951 kB]
Get:17 http://archive.ubuntu.com/ubuntu xenial-updates/restricted amd64 Packages [13.1 kB]
Get:18 http://archive.ubuntu.com/ubuntu xenial-updates/universe amd64 Packages [760 kB]
Get:19 http://archive.ubuntu.com/ubuntu xenial-updates/multiverse amd64 Packages [18.5 kB]
Get:20 http://archive.ubuntu.com/ubuntu xenial-backports/main amd64 Packages [5153 B]
Get:21 http://archive.ubuntu.com/ubuntu xenial-backports/universe amd64 Packages [7168 B]
Fetched 25.0 MB in 11s (2262 kB/s)
Reading package lists...
Removing intermediate container 759cff5b4fc7
 ---> e78cbbe7a1e9
Step 6/9 : RUN apt-get install -y --no-install-recommends apt-utils net-tools vim
 ---> Running in ab80f231e7cc
Reading package lists...
Building dependency tree...
Reading state information...
The following additional packages will be installed:
  apt libapt-inst2.0 libapt-pkg5.0 libexpat1 libgpm2 libmpdec2 libpython3.5
  libpython3.5-minimal libpython3.5-stdlib libsqlite3-0 libssl1.0.0
  mime-support vim-common vim-runtime
Suggested packages:
  aptitude | synaptic | wajig dpkg-dev apt-doc python-apt gpm ctags vim-doc
  vim-scripts vim-gnome-py2 | vim-gtk-py2 | vim-gtk3-py2 | vim-athena-py2
  | vim-nox-py2
Recommended packages:
  file
The following NEW packages will be installed:
  apt-utils libapt-inst2.0 libexpat1 libgpm2 libmpdec2 libpython3.5
  libpython3.5-minimal libpython3.5-stdlib libsqlite3-0 libssl1.0.0
  mime-support net-tools vim vim-common vim-runtime
The following packages will be upgraded:
  apt libapt-pkg5.0
2 upgraded, 15 newly installed, 0 to remove and 26 not upgraded.
Need to get 14.2 MB of archives.
After this operation, 56.1 MB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libapt-pkg5.0 amd64 1.2.25 [706 kB]
Get:2 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 apt amd64 1.2.25 [1041 kB]
Get:3 http://archive.ubuntu.com/ubuntu xenial/main amd64 libgpm2 amd64 1.20.4-6.1 [16.5 kB]
Get:4 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libapt-inst2.0 amd64 1.2.25 [55.5 kB]
Get:5 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 apt-utils amd64 1.2.25 [196 kB]
Get:6 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libexpat1 amd64 2.1.0-7ubuntu0.16.04.3 [71.2 kB]
Get:7 http://archive.ubuntu.com/ubuntu xenial/main amd64 libmpdec2 amd64 2.4.2-1 [82.6 kB]
Get:8 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libssl1.0.0 amd64 1.0.2g-1ubuntu4.10 [1083 kB]
Get:9 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libpython3.5-minimal amd64 3.5.2-2ubuntu0~16.04.4 [523 kB]
Get:10 http://archive.ubuntu.com/ubuntu xenial/main amd64 mime-support all 3.59ubuntu1 [31.0 kB]
Get:11 http://archive.ubuntu.com/ubuntu xenial/main amd64 libsqlite3-0 amd64 3.11.0-1ubuntu1 [396 kB]
Get:12 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libpython3.5-stdlib amd64 3.5.2-2ubuntu0~16.04.4 [2132 kB]
Get:13 http://archive.ubuntu.com/ubuntu xenial/main amd64 net-tools amd64 1.60-26ubuntu1 [175 kB]
Get:14 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 vim-common amd64 2:7.4.1689-3ubuntu1.2 [103 kB]
Get:15 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libpython3.5 amd64 3.5.2-2ubuntu0~16.04.4 [1360 kB]
Get:16 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 vim-runtime all 2:7.4.1689-3ubuntu1.2 [5164 kB]
Get:17 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 vim amd64 2:7.4.1689-3ubuntu1.2 [1036 kB]
debconf: delaying package configuration, since apt-utils is not installed
Fetched 14.2 MB in 6s (2105 kB/s)
(Reading database ... 4768 files and directories currently installed.)
Preparing to unpack .../libapt-pkg5.0_1.2.25_amd64.deb ...
Unpacking libapt-pkg5.0:amd64 (1.2.25) over (1.2.24) ...
Processing triggers for libc-bin (2.23-0ubuntu9) ...
Setting up libapt-pkg5.0:amd64 (1.2.25) ...
Processing triggers for libc-bin (2.23-0ubuntu9) ...
(Reading database ... 4768 files and directories currently installed.)
Preparing to unpack .../archives/apt_1.2.25_amd64.deb ...
Unpacking apt (1.2.25) over (1.2.24) ...
Processing triggers for libc-bin (2.23-0ubuntu9) ...
Setting up apt (1.2.25) ...
Processing triggers for libc-bin (2.23-0ubuntu9) ...
Selecting previously unselected package libgpm2:amd64.
(Reading database ... 4768 files and directories currently installed.)
Preparing to unpack .../libgpm2_1.20.4-6.1_amd64.deb ...
Unpacking libgpm2:amd64 (1.20.4-6.1) ...
Selecting previously unselected package libapt-inst2.0:amd64.
Preparing to unpack .../libapt-inst2.0_1.2.25_amd64.deb ...
Unpacking libapt-inst2.0:amd64 (1.2.25) ...
Selecting previously unselected package apt-utils.
Preparing to unpack .../apt-utils_1.2.25_amd64.deb ...
Unpacking apt-utils (1.2.25) ...
Selecting previously unselected package libexpat1:amd64.
Preparing to unpack .../libexpat1_2.1.0-7ubuntu0.16.04.3_amd64.deb ...
Unpacking libexpat1:amd64 (2.1.0-7ubuntu0.16.04.3) ...
Selecting previously unselected package libmpdec2:amd64.
Preparing to unpack .../libmpdec2_2.4.2-1_amd64.deb ...
Unpacking libmpdec2:amd64 (2.4.2-1) ...
Selecting previously unselected package libssl1.0.0:amd64.
Preparing to unpack .../libssl1.0.0_1.0.2g-1ubuntu4.10_amd64.deb ...
Unpacking libssl1.0.0:amd64 (1.0.2g-1ubuntu4.10) ...
Selecting previously unselected package libpython3.5-minimal:amd64.
Preparing to unpack .../libpython3.5-minimal_3.5.2-2ubuntu0~16.04.4_amd64.deb ...
Unpacking libpython3.5-minimal:amd64 (3.5.2-2ubuntu0~16.04.4) ...
Selecting previously unselected package mime-support.
Preparing to unpack .../mime-support_3.59ubuntu1_all.deb ...
Unpacking mime-support (3.59ubuntu1) ...
Selecting previously unselected package libsqlite3-0:amd64.
Preparing to unpack .../libsqlite3-0_3.11.0-1ubuntu1_amd64.deb ...
Unpacking libsqlite3-0:amd64 (3.11.0-1ubuntu1) ...
Selecting previously unselected package libpython3.5-stdlib:amd64.
Preparing to unpack .../libpython3.5-stdlib_3.5.2-2ubuntu0~16.04.4_amd64.deb ...
Unpacking libpython3.5-stdlib:amd64 (3.5.2-2ubuntu0~16.04.4) ...
Selecting previously unselected package net-tools.
Preparing to unpack .../net-tools_1.60-26ubuntu1_amd64.deb ...
Unpacking net-tools (1.60-26ubuntu1) ...
Selecting previously unselected package vim-common.
Preparing to unpack .../vim-common_2%3a7.4.1689-3ubuntu1.2_amd64.deb ...
Unpacking vim-common (2:7.4.1689-3ubuntu1.2) ...
Selecting previously unselected package libpython3.5:amd64.
Preparing to unpack .../libpython3.5_3.5.2-2ubuntu0~16.04.4_amd64.deb ...
Unpacking libpython3.5:amd64 (3.5.2-2ubuntu0~16.04.4) ...
Selecting previously unselected package vim-runtime.
Preparing to unpack .../vim-runtime_2%3a7.4.1689-3ubuntu1.2_all.deb ...
Adding 'diversion of /usr/share/vim/vim74/doc/help.txt to /usr/share/vim/vim74/doc/help.txt.vim-tiny by vim-runtime'
Adding 'diversion of /usr/share/vim/vim74/doc/tags to /usr/share/vim/vim74/doc/tags.vim-tiny by vim-runtime'
Unpacking vim-runtime (2:7.4.1689-3ubuntu1.2) ...
Selecting previously unselected package vim.
Preparing to unpack .../vim_2%3a7.4.1689-3ubuntu1.2_amd64.deb ...
Unpacking vim (2:7.4.1689-3ubuntu1.2) ...
Processing triggers for libc-bin (2.23-0ubuntu9) ...
Setting up libgpm2:amd64 (1.20.4-6.1) ...
Setting up libapt-inst2.0:amd64 (1.2.25) ...
Setting up apt-utils (1.2.25) ...
Setting up libexpat1:amd64 (2.1.0-7ubuntu0.16.04.3) ...
Setting up libmpdec2:amd64 (2.4.2-1) ...
Setting up libssl1.0.0:amd64 (1.0.2g-1ubuntu4.10) ...
debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline
debconf: unable to initialize frontend: Readline
debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC contains: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.22.1 /usr/local/share/perl/5.22.1 /usr/lib/x86_64-linux-gnu/perl5/5.22 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl/5.22 /usr/share/perl/5.22 /usr/local/lib/site_perl /usr/lib/x86_64-linux-gnu/perl-base .) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 7.)
debconf: falling back to frontend: Teletype
Setting up libpython3.5-minimal:amd64 (3.5.2-2ubuntu0~16.04.4) ...
Setting up mime-support (3.59ubuntu1) ...
Setting up libsqlite3-0:amd64 (3.11.0-1ubuntu1) ...
Setting up libpython3.5-stdlib:amd64 (3.5.2-2ubuntu0~16.04.4) ...
Setting up net-tools (1.60-26ubuntu1) ...
Setting up vim-common (2:7.4.1689-3ubuntu1.2) ...
Setting up libpython3.5:amd64 (3.5.2-2ubuntu0~16.04.4) ...
Setting up vim-runtime (2:7.4.1689-3ubuntu1.2) ...
Setting up vim (2:7.4.1689-3ubuntu1.2) ...
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/vim (vim) in auto mode
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/vimdiff (vimdiff) in auto mode
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/rvim (rvim) in auto mode
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/rview (rview) in auto mode
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/vi (vi) in auto mode
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/view (view) in auto mode
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/ex (ex) in auto mode
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/editor (editor) in auto mode
Processing triggers for libc-bin (2.23-0ubuntu9) ...
Removing intermediate container ab80f231e7cc
 ---> 68d99f6b73ca
Step 7/9 : RUN apt-get update
 ---> Running in d9859059d8c5
Hit:1 http://security.ubuntu.com/ubuntu xenial-security InRelease
Hit:2 http://archive.ubuntu.com/ubuntu xenial InRelease
Hit:3 http://archive.ubuntu.com/ubuntu xenial-updates InRelease
Hit:4 http://archive.ubuntu.com/ubuntu xenial-backports InRelease
Reading package lists...
Removing intermediate container d9859059d8c5
 ---> b0a7ed24258a
Step 8/9 : EXPOSE 443
 ---> Running in 52348b6a6d21
Removing intermediate container 52348b6a6d21
 ---> 131162842d59
Step 9/9 : RUN echo $(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}') dockerhost >> /etc/hosts
 ---> Running in 05ea7c65f0fc
Removing intermediate container 05ea7c65f0fc
 ---> 35d376e1dea6
Successfully built 35d376e1dea6
Successfully tagged craiggoddenpayne/nginx-pagespeed-beats:latest
SECURITY WARNING: You are building a Docker image from Windows against a non-Windows Docker host. All files and directories added to build context will have '-rwxr-xr-x' permissions. It is recommended to double check and reset permissions for sensitive files and directories.
```

and running it is just as simple:

```bash
docker run -it craiggoddenpayne/nginx-pagespeed-beats bash
```