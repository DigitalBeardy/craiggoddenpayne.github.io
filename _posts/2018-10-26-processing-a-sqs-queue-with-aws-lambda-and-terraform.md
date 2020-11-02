---
layout: post
title: Processing an SQS queue without manual polling, using lambda with event source triggers, built using terraform
image: /assets/img/setting-up-serverless-api-dot-net-core/cover.jpg
readtime: 12 minutes
---

I was recently working on something that would process a series of messages from a queue. In the past, this has involved some kind of polling, such as a cron job, or a service that sits idle 90% of the time. I started reading about using SQS with AWS event sourcing:

```
Lambda enables you to run code in response to events, such as S3 notifications or Amazon SNS messages. It makes it easy to process data streams from Amazon Kinesis Data Streams or Amazon DynamoDB Streams. Now, it's also easy to trigger Lambda functions by sending messages to an Amazon SQS queue.

There are no additional charges for this feature, but because the Lambda service is continuously long-polling the SQS queue the account will be charged for those API calls at the standard SQS pricing rates.
```

For in depth documentation, see the terraform documentation, its pretty good (minus examples!) 


The first thing to do, is setup an sqs queue, and deadletter.

This will create two queues, one being the deadletter, with a max message size of 256KB and a retention time of 14 days.

```
resource "aws_sqs_queue" "my-record" {
  name                      = "my-record"
  max_message_size          = 262144 #256kb
  message_retention_seconds = 1209600 #14 days
  receive_wait_time_seconds = 20
  visibility_timeout_seconds = 300
  redrive_policy            = <<EOF
{
  "deadLetterTargetArn":"${aws_sqs_queue.my-record-deadletter.arn}",
  "maxReceiveCount":4
}
EOF
}

resource "aws_sqs_queue" "my-record-deadletter" {
  name = "my-record-deadletter"
  max_message_size = 262144 #256kb
  message_retention_seconds = 1209600 #14 days
  visibility_timeout_seconds = 300
  receive_wait_time_seconds = 20
}
```

<amp-img class="center" src="/assets/img/sqs-queue-tiggers/lambda.png"
  width="600"
  height="600"
  layout="responsive">
</amp-img>

Then you will to create a lambda function to call, when a message appears on the queue:

This will create a lambda definition to call a dotnetcore 2.1 lambda function.

I set the timeout to be 5 minutes, and the memory size to be 2400. I manually uploaded the code into a bucket in s3.
```
resource "aws_lambda_function" "my-record-queue-processor" {
  function_name = "my-record-queue-processor"
  role = "${aws_iam_role.lambda-iam-role.arn}"
  handler = "my-record-queue-processor::MyRecordQueueProcessor.ProcessFunction::FunctionHandler"
  runtime = "dotnetcore2.1"
  timeout = 300
  memory_size = 2400
  s3_bucket = "${data.aws_s3_bucket.lambda-repository.bucket}"
  s3_key = "${data.aws_s3_bucket_object.my-record-queue-processor.key}"
  s3_object_version = "${data.aws_s3_bucket_object.my-record-queue-processor.version_id}"

  vpc_config {
    subnet_ids = [
      "${data.aws_subnet_ids.private.ids[0]}",
      "${data.aws_subnet_ids.private.ids[1]}",
    ]

    security_group_ids = ["${aws_security_group.lambda-access.id}"]
  }

  environment {
    variables = {
      Environment = "${terraform.workspace}"
      AwsRegion = "${var.region}"
    }
  }
}
```

Here we create the event source mapping, which will process the messages in batches of 10, against my lambda function.

```
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = 10
  event_source_arn  = "${aws_sqs_queue.my-record.arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.my-record-queue-processor.arn}"
  
}
```

Here are my references to the code repo and lambda package output

```
data "aws_s3_bucket" "lambda-repository" {
  bucket = "craiggoddenpayne-lambda-respository"
}
data "aws_s3_bucket_object" "my-record-queue-processor" {
  key = "my-records/${var.application_version}/my-record-queue-processor.zip"
  bucket = "${data.aws_s3_bucket.lambda-repository.bucket}"
}
```

Its worth looking at my iam policies also, they are very open and should really be more locked down:

```
resource "aws_iam_role" "lambda-iam-role" {
  name = "my-record-queue-processorlambda-iam-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda-s3-read-write-access" {
  name = "my-record-queue-processorlambda-s3-read-write"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
        "Resource": [
          "*"
      ]
    }
  ]
}
EOF
}


resource "aws_iam_policy" "lambda-vpc" {
  name = "my-record-queue-processorlambda-vpc"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Effect": "Allow",
        "Resource": [
          "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda-logs" {
  name = "my-record-queue-processorlambda-logs"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents",
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ],
      "Effect": "Allow",
        "Resource": [
          "*"
      ]
    }
  ]
}
EOF
}


resource "aws_iam_policy" "lambda-sqs-access" {
  name = "my-record-queue-processorsqs-access"
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [{
      "Effect": "Allow",
      "Action": "sqs:*",
      "Resource": "${aws_sqs_queue.my-record.arn}"
   }]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda-s3-read-write-access" {
  name = "my-record-queue-processorlambda-s3-read-write-access"
  policy_arn = "${aws_iam_policy.lambda-s3-read-write-access.arn}"
  roles = [
    "${aws_iam_role.lambda-iam-role.name}"
  ]
}

resource "aws_iam_policy_attachment" "lambda-vpc" {
  name = "my-record-queue-processorlambda-vpc-access"
  policy_arn = "${aws_iam_policy.lambda-vpc.arn}"
  roles = [
    "${aws_iam_role.lambda-iam-role.name}"
  ]
}

resource "aws_iam_policy_attachment" "lambda-logs" {
  name = "my-record-queue-processorlambda-logging"
  policy_arn = "${aws_iam_policy.lambda-logs.arn}"
  roles = [
    "${aws_iam_role.lambda-iam-role.name}"
  ]
}

resource "aws_iam_policy_attachment" "lambda-sqs-access" {
  name = "my-record-queue-processorlambda-sqs-access"
  policy_arn = "${aws_iam_policy.lambda-sqs-access.arn}"
  roles = [
    "${aws_iam_role.lambda-iam-role.name}"
  ]
}
```


Once deployed, the code will happily chip away at messages stored on the queue, pushing them to my Lambda function:

```
    public class ProcessFunction
    {
        [LambdaSerializer(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]
        public string FunctionHandler(SQSEvent @event, ILambdaContext context)
        {
            Console.WriteLine("SQS Lambda called with " + @event.Records.Count + "x records");
            return null;
        }
    }
```


<amp-img class="center" src="/assets/img/sqs-queue-tiggers/dotnet.png"
  width="350"
  height="230"
  layout="responsive">
</amp-img>