---
layout: post
title: Log Rotate in Unix
image: /assets/img/2017-10-1-log-rotate-unix/logrotate.jpg
readtime: 4 minutes
---
Recently I've been doing some work with analytics and tracking and came across log rotation in Linux.


The problem I came across was when parsing nginx logs to build up user journeys. Because the log was set to just keep logging forever, when the logs reached the maximum capacity due to disk size, it occasionally caused nginx to return a 503 response to the caller.


I realised I had two options;


Increase the disk size (which would have meant decommissioning the vm in azure, taking it out of the load balancer, resizing and putting it back in) which wasn't really an option as it was a temporary fix.


Setup log rotate, so the vm becomes self maintaining (since we are exporting the logs to our analytics platform, keeping more than a few days of logs is pretty pointless, as long as there is sufficient time to reprocess a log if it fails for example)


I was surprised how easy it was to setup!


The Ubuntu VM I was using for nginx needed to have logrotate installed (I just used aptitude) and this automatically added it to cron.daily


cron is configured in  /etc/crontab and its possible to change the time it runs, but I was happy with the default, as long as it was run at roughly the same time daily.


The documentation is pretty good online for this, and within a few minutes I managed to get it all setup and working.
I used a basic configuration to rotate the logs each day, keeping a maximum of 5 daily back ups:

```bash
/var/log/nginx/* {
daily
create 0644 admin admin
copytruncate
rotate 5
compress
}
```


This means we don't have to worry anymore about the disk running out of space, and our analytics platform can keep on ticking without us having to stop filebeat or having the occasional 503 error being returned from nginx.