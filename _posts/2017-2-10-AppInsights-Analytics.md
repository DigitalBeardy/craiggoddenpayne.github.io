---
layout: post
title: App Insights Analytics
image: /assets/img/2017-2-10-AppInsights-Analytics/appinsights.jpg
readtime: 3 minutes
---

I've been playing around with azure app insights analytics again. I focused on seeing if there is a way that i could work out a users journey through a website, using simple query. I know this is easy to do with Google analytics, but I thought I would see if I could do something similar with azure app insights offering.

```bash
pageviews
| where timestamp > ago(24h)
| project session_id, url, timestamp, client_city, client_OS
| order by session_id asc, timestamp asc 
```

Turns out its quite simple, and you can see the journey they took, on one device

Its easy to join tables such as pageViews and exceptions, which will show the amount of exceptions that have occured, on a certain page view, which means you can focus efforts to reduce the amount of unhandled exceptions on pages which get more traffic

```bash
requests
| where timestamp > ago(1d)
| join kind=leftouter (
    exceptions
    | where timestamp > ago(1d)
) on operation_Id
| where success == "False"
| summarize exceptionCount=count() by tostring(parseurl(url)["Path"])
| order by exceptionCount desc
| render piechart 
```

