---
layout: post
title: Analysing network traffic for your ALB, using elasticsearch and lambda
image: /assets/img/network-logging/cover.png
readtime: 10 minutes
tags: network logging elasticsearch
---

At my job, I utilised my 10% hack time at work to build a system to analyse network traffic.

I know there are tools out there like beats, which can do something similar, but I wanted something that I could run serverless, and invoke using a cron job or something similar.

At the time they had no form of logging in place at the time, and a lot of outages, so it made sense to have some way to visualise with something like elasticsearch.

<amp-img src="/assets/img/network-logging/elasticsearch.png"
  width="558"
  height="300"
  layout="responsive">
</amp-img>


Here is the code I used to process network logs, which as stored in S3 automatically from the ALB. I'll go onto how this is trigger further down

```
public class Function
{
    private readonly IAmazonS3 _s3Client;
    private readonly IElasticSearchAdapter _elasticSearchAdapter;
    private readonly IParser _parser;

    public Function()
    {
        _s3Client = new AmazonS3Client();
        _elasticSearchAdapter = new ElasticSearchAdapter();
        _parser = new Parser();
    }

    public Function(IAmazonS3 s3Client)
    {
        _s3Client = s3Client;
        _elasticSearchAdapter = new ElasticSearchAdapter();
        _parser = new Parser();
    }

    public void FunctionHandler(ILambdaContext context)
    {
        var logS3Objects = _s3Client.ListObjectsAsync("prod-network-logging").GetAwaiter().GetResult();
        foreach (var s3Object in logS3Objects.S3Objects)
        {
            try
            {
                using (var response = _s3Client.GetObjectStreamAsync(s3Object.BucketName, s3Object.Key, null).GetAwaiter().GetResult())
                {
                    byte[] dataBuffer = new byte[4096];
                    using (var gzipStream = new GZipInputStream(response))
                    using (var decodedStream = new MemoryStream())
                    {
                        StreamUtils.Copy(gzipStream, decodedStream, dataBuffer);
                        gzipStream.Flush();
                        decodedStream.Flush();
                        decodedStream.Position = 0;
                        using (var reader = new StreamReader(decodedStream))
                        {
                            var lines = new List<string>();
                            while (!reader.EndOfStream)
                                lines.Add(reader.ReadLineAsync().GetAwaiter().GetResult());

                            Console.WriteLine("There looks like " + lines.Count() + " log entries to be processed.");
                            var count = 1;
                            var data = lines.Select(x => _parser.Parse(x));
                            _elasticSearchAdapter.CreateElasticRecord(data);
                            Console.WriteLine("Wrote " + count + " records to elasticsearch.");
                            _s3Client.DeleteObjectAsync(s3Object.BucketName, s3Object.Key).GetAwaiter().GetResult();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                context.Logger.LogLine(e.Message);
                context.Logger.LogLine(e.StackTrace);
            }
        }
    }
}
```

And the implementation of the ElasticSearch adapter:

```
public class ElasticSearchAdapter : IElasticSearchAdapter
{
    private readonly HttpClient _esClient;

    public ElasticSearchAdapter()
    {
        var endpoint = Environment.GetEnvironmentVariable("ElasticSearchEndpoint");
        _esClient = new HttpClient {BaseAddress = new Uri("https://" + endpoint)};
    }
    
    public void CreateElasticRecord(IEnumerable<NetworkLog> data)
    {
        foreach (var batch in data.Batch(100))
        {
            var index = $"logs-{DateTime.Now.Year.ToString("00")}-{DateTime.Now.Month.ToString("00")}-{DateTime.Now.Day.ToString("00")}";
            var uri = new Uri("_bulk", UriKind.Relative);

            var messageBody = "";
            foreach (var item in batch)
            {
                messageBody += "{\"create\":{\"_index\":\"" + index + "\",\"_type\":\"network_log\",\"_id\":\""+ Guid.NewGuid() + "\"}}\r\n" +
                                JsonConvert.SerializeObject(item) + "\r\n";
                
            }

            var messageRequest = new HttpRequestMessage(HttpMethod.Post, uri)
            {
                Content = new StringContent(messageBody, Encoding.UTF8, "application/json")
            };
            var result = _esClient.SendAsync(messageRequest).GetAwaiter().GetResult();
            if (result.StatusCode != HttpStatusCode.OK)
                Console.WriteLine("Something didn't look quite right: " + result.StatusCode);
        }
    }
}
```

Class representation of the log entry

```
public class NetworkLog
{
    public string type { get; set; }
    public DateTime requestTime{ get; set; }
    public string resourceId{ get; set; }
    public string internalIp{ get; set; }
    public int internalPort{ get; set; }
    public string externalIp{ get; set; }
    public int externalPort{ get; set; }
    public decimal processingTime{ get; set; }
    public decimal targetProcessingTime{ get; set; }
    public decimal responseProcessingTime{ get; set; }
    public int statusCode { get; set; }
    public int targetStatusCode{ get; set; }
    public long receivedBytes{ get; set; }
    public long sendBytes{ get; set; }
    public string request{ get; set; }
    public string userAgent{ get; set; }
    public string sslCipher{ get; set; }
    public string sslProtocol{ get; set; }
    public string traceId{ get; set; }
    public string domainName{ get; set; }
    public int ruleId{ get; set; }
}
```

And finally the parser

```
public class Parser : IParser
{
    private readonly IParsingIntelligenceLayer _intelligentStats;

    public Parser()
    {
        _intelligentStats = new ParsingIntelligenceLayer();
    }
    
    public NetworkLog Parse(string logEntry)
    {
        var originalLog = logEntry;
        try
        {
            var log = new NetworkLog();
            if (logEntry == null || string.IsNullOrWhiteSpace(logEntry) || logEntry.StartsWith(" ") || logEntry.Trim() == "" )
                return null;

            //type
            log.type = logEntry.Split(' ').First();
            logEntry = logEntry.Remove(0, log.type.Length + 1);

            //timestamp
            DateTime.TryParse(logEntry.Split(' ').First(), new DateTimeFormatInfo(), DateTimeStyles.RoundtripKind, out var timestamp);
            log.requestTime = timestamp;
            logEntry = logEntry.Remove(0, logEntry.IndexOf('Z') + 2);
            
            //resourceId
            log.resourceId = logEntry.Split(' ').First();
            logEntry = logEntry.Remove(0, log.resourceId.Length + 1);

            //externalIp
            log.externalIp = logEntry.Split(':').First();
            logEntry = logEntry.Remove(0, log.externalIp.Length + 1);
            log.externalPort = int.Parse(logEntry.Split(' ').First());
            logEntry = logEntry.Remove(0, log.externalPort.ToString().Length + 1);
            
            //internalIp - might come through as -
            if (logEntry.StartsWith("-"))
            {
                log.internalIp = "-";
                log.internalPort = 0;
                logEntry = logEntry.Remove(0, 2);
            }
            else
            {
                log.internalIp = logEntry.Split(':').First();
                logEntry = logEntry.Remove(0, log.internalIp.Length + 1);
                log.internalPort = int.Parse(logEntry.Split(' ').First());
                logEntry = logEntry.Remove(0, log.internalPort.ToString().Length + 1);
            }

            //processing time
            var processingTime = logEntry.Split(' ').First();
            log.processingTime = decimal.Parse(processingTime);
            logEntry = logEntry.Remove(0, processingTime.Length + 1);

            //targetProcessingTime
            var targetProcessingTime = logEntry.Split(' ').First();
            log.targetProcessingTime = decimal.Parse(targetProcessingTime);
            logEntry = logEntry.Remove(0, targetProcessingTime.Length + 1);

            //responseProcessingTime
            var responseProcessingTime = logEntry.Split(' ').First();
            log.responseProcessingTime = decimal.Parse(responseProcessingTime);
            logEntry = logEntry.Remove(0, responseProcessingTime.Length + 1);
            
            //statusCode
            log.statusCode = int.Parse(logEntry.Split(' ').First());
            logEntry = logEntry.Remove(0, log.statusCode.ToString().Length + 1);
            
            //targetStatusCode - might come through as -
            if (logEntry.StartsWith("-"))
            {
                log.targetStatusCode = 0;
                logEntry = logEntry.Remove(0, 2);
            }
            else
            {
                log.targetStatusCode = int.Parse(logEntry.Split(' ').First());
                logEntry = logEntry.Remove(0, log.targetStatusCode.ToString().Length + 1);
            }

            //receivedBytes
            log.receivedBytes = long.Parse(logEntry.Split(' ').First());
            logEntry = logEntry.Remove(0, log.receivedBytes.ToString().Length + 1);
            
            //sendBytes
            log.sendBytes = long.Parse(logEntry.Split(' ').First());
            logEntry = logEntry.Remove(0, log.sendBytes.ToString().Length + 1);

            //request
            logEntry = logEntry.Remove(0, 1); //remove opening
            log.request = logEntry.Split("\" \"").First();
            logEntry = logEntry.Remove(0, log.request.Length + 2);

            //userAgent
            logEntry = logEntry.Remove(0, 1); //remove opening
            log.userAgent = logEntry.Split("\" ").First();
            logEntry = logEntry.Remove(0, log.userAgent.Length + 2);

            //sslCipher
            log.sslCipher = logEntry.Split(' ').First();
            logEntry = logEntry.Remove(0, log.sslCipher.Length + 1);
            
            //sslProtocol
            log.sslProtocol = logEntry.Split(' ').First();
            logEntry = logEntry.Remove(0, log.sslProtocol.Length + 1);

            //targetGroupArn
            var targetGroupArn = logEntry.Split(' ').First();
            logEntry = logEntry.Remove(0, targetGroupArn.Length + 1);
            
            //traceId
            logEntry = logEntry.Remove(0, 1); //remove opening
            log.traceId = logEntry.Split("\" \"").First();
            logEntry = logEntry.Remove(0, log.traceId.Length + 2);
            
            //domainName
            logEntry = logEntry.Remove(0, 1); //remove opening
            log.domainName = logEntry.Split("\" \"").First();
            logEntry = logEntry.Remove(0, log.domainName.Length + 2);
            
            //certArn
            logEntry = logEntry.Remove(0, 1); //remove opening
            var certArn = logEntry.Split("\" ").First();
            logEntry = logEntry.Remove(0, certArn.Length + 2);

            //ruleId                
            if (logEntry.StartsWith("-"))
            {
                log.ruleId = -1;
                logEntry = logEntry.Remove(0, 2);
            }
            else
            {
                log.ruleId = int.Parse(logEntry.Split(' ').First());
                logEntry = logEntry.Remove(0, log.ruleId.ToString().Length + 1);
            }
            
            return _intelligentStats.Improve(log);
        }
        catch (Exception ex)
        {
            Console.WriteLine("Unable to parse " + originalLog);
            Console.WriteLine(ex);
            throw;
        }
    }
}
```

Then the terraform to deploy (some have been removed / modified for security reasons)

Elasticsearch cluster

```
resource "aws_elasticsearch_domain" "network-logging" {
  domain_name           = "network-logging"
  elasticsearch_version = "6.3"

  cluster_config {
    instance_type            = "t2.small.elasticsearch"
    instance_count           = 1
    dedicated_master_enabled = false
    zone_awareness_enabled   = false
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = 35
  }

  encrypt_at_rest {
    enabled = false
  }

  vpc_options {
    subnet_ids = ["${data.aws_subnet_ids.data.ids[0]}"]

    security_group_ids = [
      "${aws_security_group.network-logging.id}",
    ]
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  snapshot_options {
    automated_snapshot_start_hour = 00
  }

  tags {
    Domain = "network-logging"
  }

  access_policies = <<CONFIG
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:eu-west-2:${data.aws_caller_identity.current.account_id}:domain/network-logging/*"
    }
  ]
  }
  CONFIG
}


resource "aws_security_group" "network-logging" {
  *REMOVED*
}
```

Iam definition

```
resource "aws_iam_policy" "other-permissions" {
  name        = "network-logging-policy"
  path        = "/"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LambdaLogCreation",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect":"Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ESPermission",
      "Effect": "Allow",
      "Action": [
        "es:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${data.aws_s3_bucket.network-logging.arn}", "${module.aws-lambda-dotnet.lambda-repository-arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": ["${data.aws_s3_bucket.network-logging.arn}", "${module.aws-lambda-dotnet.lambda-repository-arn}"]
    }
  ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "other-permissions-policy-attachment" {
  role       = "${module.aws-lambda-dotnet.iam_role_name}"
  policy_arn = "${aws_iam_policy.other-permissions.arn}"
}

```

The lambda definition (we use a module for this, and unfortunately can't post the code, but it basically wraps up the creation of a lambda, and permissions surrounding that)

```
module "aws-lambda-dotnet" "lambda" {
  source = "git::git@github.com:******/terraform-modules.git//aws-lambda-dotnet?ref=v1.0.36"
  function_type = "vpc"
  name = "network-logging"
  application_version = "${var.application_version}"
  environment_variables = {
      Environment = "${terraform.workspace}"
      AwsRegion = "eu-west-2"
      ElasticSearchEndpoint = "${aws_elasticsearch_domain.network-logging.endpoint}"
  }
  handler = "network-logging::NetworkLogging.Function::FunctionHandler"
  runtime = "dotnetcore2.1"
  timeout = 300
  memory_size = 1024
}
```

And finally the trigger, which calls the lambda function, every 5 minutes.

```
resource "aws_cloudwatch_event_rule" "every_five_minutes" {
  name = "every-five-minutes"
  description = "Fires every five minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "check_foo_every_five_minutes" {
  rule = "${aws_cloudwatch_event_rule.every_five_minutes.name}"
  target_id = "check_foo"
  arn = "${module.aws-lambda-dotnet.function_arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_logger" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${module.aws-lambda-dotnet.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.every_five_minutes.arn}"
}
```



<amp-img src="/assets/img/network-logging/404s.png"
  width="2478"
  height="942"
  layout="responsive">
</amp-img>


<amp-img src="/assets/img/network-logging/ips.png"
  width="2490"
  height="970"
  layout="responsive">
</amp-img>


<amp-img src="/assets/img/network-logging/mostvisited.png"
  width="2520"
  height="954"
  layout="responsive">
</amp-img>


<amp-img src="/assets/img/network-logging/statuscodes.png"
  width="2468"
  height="1442"
  layout="responsive">
</amp-img>
