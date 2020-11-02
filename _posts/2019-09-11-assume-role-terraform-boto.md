---
layout: post
title: Using boto to consume a service assuming a role within another account with terraform.
image: /assets/img/boto-consume-service-assume-role-terraform/cover.png
readtime: 10 minutes
---

I came across a scenario today, when working with a task management platform, where the task runner (which was using python) needed to be able to assume a role, in another account to be able to consume some resources (dynamodb).

Since the platform the task runner was running on was fargate, I looked at the options and used assume role to be able to assume the identity of the secondary account from the running task role, and consume the resources on behalf of it.

<amp-img src="/assets/img/boto-consume-service-assume-role-terraform/diagram.png"
  width="1160"
  height="614"
  layout="responsive">
</amp-img>

Below is a bit of a write up of how I did this:


#### Create a task role for your fargate task in Account1

```
resource "aws_iam_role" "task_iam_role" {
  name               = "my-fargate-task-role"
  assume_role_policy = "${file("${path.module}/policies/iam/ecs-task-service-trust.json")}"
}
```

#### The assume role policy should look something like this: ecs-task-service-trust.json

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

#### Create a role for the service you want to consume in Account2


```
resource "aws_iam_role" "switch_role" {
  name               = "switch-role"
  assume_role_policy = "${data.template_file.trust_policy_file.rendered}"
}
```

#### The assume role policy should look something like this: trust_policy_file.json

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${ACCOUNT1_ID}:role/my-fargate-task-role"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

#### The second role should also contain a policy with the permissions to access the resources it needs.

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["dynamodb:*"],
      "Resource": "arn:aws:dynamodb:eu-west-1:${ACCOUNT2_ID}:table/*"
    }
  ]
}
```

#### Within the python application, create a function that will assume a role, based on the ARN, and return a session pre-authenticated with the switch role

```
def assumed_role_session(role_arn: str):
    role = boto3.client('sts').assume_role(RoleArn=role_arn, RoleSessionName='switch-role')
    credentials = role['Credentials']
    aws_access_key_id = credentials['AccessKeyId']
    aws_secret_access_key = credentials['SecretAccessKey']
    aws_session_token = credentials['SessionToken']
    return boto3.session.Session(
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
        aws_session_token=aws_session_token)
```

#### Consume the service, such as dynamodb in this example, as the assumed role, from a fargate task within ACCOUNT1

```
def call_dynamo(*args, **kwargs):
    assumed_session = assumed_role_session('arn:aws:iam::ACCOUNT2_ID:role/switch-role')
    dynamo_client = assumed_session.client('dynamodb')
    response = dynamo_client.list_tables(Limit=100)
    print(str(response))
```

#### Testing it out

You can test this easily using the aws cli with a command like this:

```
AWS_PROFILE=my-profile \ 
  aws sts assume-role \ 
  --role-arn "arn:aws:iam::XXXXXXXX:role/switch-role"
```

If a set of temporary credentials are returned, then it worked!