---
layout: post
title: Visualising AWS Glue history in Spark UI History Server
image: /assets/img/spark/cover.png
readtime: 2 minutes
---

I recently had to try and spot why a job running in AWS Glue was not performing as expected.

Glue outputs a huge amount of logging information, most of which I found to be irrelevant to what I was trying to diagnose.

When you run a glue job in aws, you can output the spark logs, to an S3 bucket, which can then be visualised using the spark history ui server.

SparkUI is not the easiest application to setup, but I found a docker image running exactly what I needed


I copied the spark logs into an events directory, then built and ran the container.


Dockerfile:

```
ARG SPARK_IMAGE=gcr.io/spark-operator/spark:v2.4.4
FROM ${SPARK_IMAGE}

RUN apk --update add coreutils

RUN mkdir /tmp/spark-events

ENV SPARK_NO_DAEMONIZE TRUE
ENTRYPOINT ["/opt/spark/sbin/start-history-server.sh"]
```

I built and ran the image

```
docker build . -t spark-history-server
docker run -it -v ${PWD}/events:/tmp/spark-events -p 18080:18080 spark-history-server
```

I could then view the results at http://localhost:18080

<amp-img src="/assets/img/spark/sparkui.png"
  width="2834"
  height="1216"
  layout="responsive">
</amp-img>
