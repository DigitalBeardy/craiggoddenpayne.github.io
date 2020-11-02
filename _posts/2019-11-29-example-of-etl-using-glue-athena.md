---
layout: post
title: Example of an ETL job in AWS Glue, and query in AWS Athena
image: /assets/img/glue-athena-1/cover.png
readtime: 6 minutes
---

I hope with this post to show a simple end to end run through of using AWS Glue to transform data from a format, into a
more queryable format, and then query it using AWS Athena. 

I'm aiming to show this through the console only, 
with more focus on how to automate this with terraform in the future.

First of all, I downloaded a data set to use as my example.
In this case, it was some apache logs, which I then broke down into 5 pieces, to simulate that the logs were uploaded 
at 5 different times.

Here are links to the data sets that I used:

[Github](https://github.com/elastic/examples/blob/master/Common%20Data%20Formats/apache_logs/apache_logs)

Or you can see my split versions here:

[log 1](https://craig.goddenpayne.co.uk/assets/img/glue-athena-1/log1.log)
[log 2](https://craig.goddenpayne.co.uk/assets/img/glue-athena-1/log2.log)
[log 3](https://craig.goddenpayne.co.uk/assets/img/glue-athena-1/log3.log)
[log 4](https://craig.goddenpayne.co.uk/assets/img/glue-athena-1/log4.log)
[log 5](https://craig.goddenpayne.co.uk/assets/img/glue-athena-1/log5.log)

I then uploaded the data files into my S3 bucket, keeping the data in the log format.

<amp-img src="/assets/img/glue-athena-1/2-target-files-log-s3.png"
  width="1216"
  height="1220"
  layout="responsive">
</amp-img>

I then go to AWS, search for Glue, then head to the Databases tab.
I create a database called craig-test

When I check the tables section, I see the message that no tables have been defined in the data catalogue, which is the case 
because I have yet to do anything. So the next thing to do is for me to create a crawler.

<amp-img src="/assets/img/glue-athena-1/1-database-no-tables.png"
  width="2382"
  height="532"
  layout="responsive">
</amp-img>

I create the crawler, looking at the S3 bucket, and set it to write to the database data catalogue that I created before.


<amp-img src="/assets/img/glue-athena-1/3-crawler-setup.png"
  width="2164"
  height="1300"
  layout="responsive">
</amp-img>

Since I set the crawler to be on demand, I need to run it once I finished creating the crawler.

The Glue crawler pretty quickly determined that the format of the log was in apache format, and was able to define the schema for me.


<amp-img src="/assets/img/glue-athena-1/4-etl-setup.png"
  width="2452"
  height="1222"
  layout="responsive">
</amp-img>

<amp-img src="/assets/img/glue-athena-1/5-etl-schema.png"
  width="1622"
  height="1018"
  layout="responsive">
</amp-img>


The next stage, I wanted to create an ETL job, which will take the logs, in apache format and transform them into columnar data in parquet format, 
so that it is much more efficent and cost effective to query in Athena.

I created an Glue job, added the data source (craig-test bucket) and the destination as (craig-test-processed bucket)
I then selected that I wanted to have the destination in parquet format.
The apache spark code was auto generated for me, which means I can easily tweak and make changes if I need to.

<amp-img src="/assets/img/glue-athena-1/6-spark-auto-gen.png"
  width="2854"
  height="1256"
  layout="responsive">
</amp-img>

<amp-img src="/assets/img/glue-athena-1/7-source-dest-mapping.png"
  width="2416"
  height="1206"
  layout="responsive">
</amp-img>

I then run the job, and after a few minutes the job is completed.
My first run failed.

Here are some of the logs generated in cloudwatch, they are pretty easy to figure out what is going on, and detailed
enough to be able to intervene if things did not work as expected.

<amp-img src="/assets/img/glue-athena-1/8-glue-logging.png"
  width="2386"
  height="648"
  layout="responsive">
</amp-img>

It was due to permissions, I forgot to allow the glue role to have access to my output bucket in IAM.

<amp-img src="/assets/img/glue-athena-1/9-iam-changes.png"
  width="1390"
  height="898"
  layout="responsive">
</amp-img>

I updated that, and tried running the job again

<amp-img src="/assets/img/glue-athena-1/10-job-run.png"
  width="2378"
  height="478"
  layout="responsive">
</amp-img>

I check the s3 processed bucket and the parquet files are there ready for me to query using athena.

<amp-img src="/assets/img/glue-athena-1/11-parquet-destination.png"
  width="2614"
  height="1418"
  layout="responsive">
</amp-img>

The next stage now though, is to rebuild the schema to include the new data sets I have in the transformed columnar parquet format.
So I go back to glue, create a new crawler, but this time crawl the S3 bucket I created containing the processed files.

<amp-img src="/assets/img/glue-athena-1/20-crawl-parquet.png"
  width="2036"
  height="1414"
  layout="responsive">
</amp-img>

Once ran, and the schema has been added to the data catalogue, it is time to move over to Athena for querying.

Note, it is fine to query the data in the log format without the ETL process of generating to parquet.
The problem is, it is slow and costly, so it is likely you would also want to use something like parquet.
Once in Athena, I can query the data from the logs, in a very fast, cost efficient way as if it were normal structured data

<amp-img src="/assets/img/glue-athena-1/21-query-athena-1.png"
  width="2044"
  height="1248"
  layout="responsive">
</amp-img>

<amp-img src="/assets/img/glue-athena-1/22-query-athena-2.png"
  width="2046"
  height="1306"
  layout="responsive">
</amp-img>

The difference in this simple query, is with the parquet data. 
If you look at the amount of data processed, you can see how much more expensive it would be

<amp-img src="/assets/img/glue-athena-1/24-comparison.png"
  width="2674"
  height="308"
  layout="responsive">
</amp-img>