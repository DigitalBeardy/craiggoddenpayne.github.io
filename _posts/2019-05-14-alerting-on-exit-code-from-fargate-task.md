---
layout: post
title: Alerting on a failed fargate task - built using cloud formation
image: /assets/img/cf-alerting/cover.png
readtime: 8 minutes
---

Most of my posts on my blog so far, with regards to infrastructure as code have been related to terraform, so I thought I would write a post about cloud formation.



I've recently been working on a project, that involved some kind of conversion. The tool that was used for conversion was a unix based program, so made sense to run this one off task when needed as a fargate task.


<amp-img src="/assets/img/cf-alerting/fargate.png"
  width="300"
  height="130"
  layout="responsive">
</amp-img>


Another important thing I needed was to report on whether or not the task had completed successfully. 

The solution I settled on, was a cloudwatch alarm, which is triggered based on the exit code from the fargate task.  

The alarm would trigger an SNS notification, and then users could be notified by email as configured via an SNS subscription.

First I need to define the ecr repository, so that I can upload my built docker image.

```
Resources:
  MyApplicationRepository:
    Type: AWS::ECR::Repository
    Properties:
      RepositoryName: !Sub "${AppName}"
      RepositoryPolicyText:
        Version: "2012-10-17"
        Statement:
          - Sid: MyApplicationPushPull
            Effect: Allow
            Principal:
              AWS:
                - !GetAtt MyApplicationTaskExecutionRole.Arn
            Action:
              - ecr:GetDownloadUrlForLayer
              - ecr:BatchGetImage
              - ecr:BatchCheckLayerAvailability
              - ecr:PutImage
              - ecr:InitiateLayerUpload
              - ecr:UploadLayerPart
              - ecr:CompleteLayerUpload
 ```

Then I need to create the task definition, which will define how the task will run

```
  MyApplicationTask:
    Type: AWS::ECS::TaskDefinition
    Properties:
       ContainerDefinitions:
         - Memory: 1024
           Cpu: 256
           Image: !Sub "${AWS::AccountId}.dkr.ecr.eu-west-2.amazonaws.com/${AppName}:latest"  
           Name: !Sub "${AppName}"
           LogConfiguration:
             LogDriver: "awslogs"
             Options:
               awslogs-group: !Sub "/ecs/${AppName}"
               awslogs-region: eu-west-2
               awslogs-stream-prefix: ecs
       TaskRoleArn: !GetAtt MyApplicationTaskExecutionRole.Arn
       ExecutionRoleArn: !GetAtt MyApplicationTaskExecutionRole.Arn
       Family: !Sub "${AppName}"
       NetworkMode: awsvpc
       Cpu: 256
       Memory: 1024
       RequiresCompatibilities:
         - FARGATE
           
```

Then create a role to be able to execute the task

```
  MyApplicationTaskExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: MyApplicationTaskExecutionRole
      AssumeRolePolicyDocument:
        Statement:
          - Effect: Allow
            Principal:
              Service: "ecs-tasks.amazonaws.com"
            Action:
              - sts:AssumeRole
```

And add associated policies for ecr access and logging

```
  MyApplicationRepositoryTaskPolicyEcr:
    Type: AWS::IAM::Policy
    Properties:
      PolicyName: MyApplicationRepositoryTaskPolicyEcr
      Roles: [ !Ref MyApplicationTaskExecutionRole ]
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Resource: "*"
            Action:
              - ecr:GetAuthorizationToken  

  MyApplicationRepositoryTaskPolicyLogging:
    Type: AWS::IAM::Policy
    Properties:
      PolicyName: MyApplicationRepositoryTaskPolicyLogging
      Roles: [ !Ref MyApplicationTaskExecutionRole ]
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Resource: "*"
            Action:
              - cloudwatch:*
              - sns:*

          - Effect: Allow
            Resource: !Sub "arn:aws:logs:eu-west-2:${AWS::AccountId}:*"
            Action:
              - logs:CreateLogStream
              - logs:PutLogEvents
              - logs:DescribeLogStreams
              - logs:GetLogEvents
```

I also need to create a log group in case I want to debug any application errors

```
  MyApplicationLogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub "/ecs/${AppName}"
      RetentionInDays: 30
```

Now the interesting bit. I can create an alarm, which will trigger if at least 1 event is raised

```
  MyApplicationFailedAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties: 
      AlarmName: "MyApplicationTaskFailed"
      AlarmDescription: "My application has failed"
      Namespace: "AWS/Events"
      MetricName: "TriggeredRules"
      Period: 60
      Statistic: Minimum
      Threshold: "0"
      TreatMissingData: "ignore"
      ComparisonOperator: GreaterThanThreshold
      EvaluationPeriods: 1
      ActionsEnabled: true    
      AlarmActions:
        - !Sub "arn:aws:sns:eu-west-2:${AWS::AccountId}:AlertHigh"
```

And now the actual rule, which will match on the name of the running task, the last status being stopped, and the exit code matching 1

```
  MyApplicationFailedRule:
    Type: AWS::Events::Rule
    Properties:
      Description: My Application has returned exit code 1
      Name: my-application-failure
      EventPattern: !Sub '{"detail-type": ["ECS Task State Change"],"source": ["aws.ecs"],"detail": {"containers": {"name": ["${AppName}"],"exitCode": [1],"lastStatus": ["STOPPED"]}}}'
      Targets: 
        - Arn: !Sub "arn:aws:sns:eu-west-2:${AWS::AccountId}:AlertHigh"
          Id: MyApplicationFailed
```

* Note that I found a bug in cloudformation, which if you specify the exit code within the yaml syntax, it will treat as a string rather than a number, and not match events. To prevent the issue, I supplied the event pattern as a string rather than an object.

<amp-img src="/assets/img/cf-alerting/cloudwatch.png"
  width="696"
  height="320"
  layout="responsive">
</amp-img>

And thats it, the full code example below:

```
Parameters:
  AppName:
    Type: String
    Default: "my-application"
  
Resources:
  MyApplicationRepository:
    Type: AWS::ECR::Repository
    Properties:
      RepositoryName: !Sub "${AppName}"
      RepositoryPolicyText:
        Version: "2012-10-17"
        Statement:
          - Sid: MyApplicationPushPull
            Effect: Allow
            Principal:
              AWS:
                - !GetAtt MyApplicationTaskExecutionRole.Arn
            Action:
              - ecr:GetDownloadUrlForLayer
              - ecr:BatchGetImage
              - ecr:BatchCheckLayerAvailability
              - ecr:PutImage
              - ecr:InitiateLayerUpload
              - ecr:UploadLayerPart
              - ecr:CompleteLayerUpload
 
  MyApplicationTask:
    Type: AWS::ECS::TaskDefinition
    Properties:
       ContainerDefinitions:
         - Memory: 1024
           Cpu: 256
           Image: !Sub "${AWS::AccountId}.dkr.ecr.eu-west-2.amazonaws.com/${AppName}:latest"  
           Name: !Sub "${AppName}"
           LogConfiguration:
             LogDriver: "awslogs"
             Options:
               awslogs-group: !Sub "/ecs/${AppName}"
               awslogs-region: eu-west-2
               awslogs-stream-prefix: ecs
       TaskRoleArn: !GetAtt MyApplicationTaskExecutionRole.Arn
       ExecutionRoleArn: !GetAtt MyApplicationTaskExecutionRole.Arn
       Family: !Sub "${AppName}"
       NetworkMode: awsvpc
       Cpu: 256
       Memory: 1024
       RequiresCompatibilities:
         - FARGATE
   
  MyApplicationTaskExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: MyApplicationTaskExecutionRole
      AssumeRolePolicyDocument:
        Statement:
          - Effect: Allow
            Principal:
              Service: "ecs-tasks.amazonaws.com"
            Action:
              - sts:AssumeRole

  MyApplicationRepositoryTaskPolicyEcr:
    Type: AWS::IAM::Policy
    Properties:
      PolicyName: MyApplicationRepositoryTaskPolicyEcr
      Roles: [ !Ref MyApplicationTaskExecutionRole ]
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Resource: "*"
            Action:
              - ecr:GetAuthorizationToken  

  MyApplicationRepositoryTaskPolicyLogging:
    Type: AWS::IAM::Policy
    Properties:
      PolicyName: MyApplicationRepositoryTaskPolicyLogging
      Roles: [ !Ref MyApplicationTaskExecutionRole ]
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Resource: "*"
            Action:
              - cloudwatch:*
              - sns:*

          - Effect: Allow
            Resource: !Sub "arn:aws:logs:eu-west-2:${AWS::AccountId}:*"
            Action:
              - logs:CreateLogStream
              - logs:PutLogEvents
              - logs:DescribeLogStreams
              - logs:GetLogEvents

  MyApplicationLogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub "/ecs/${AppName}"
      RetentionInDays: 30

  MyApplicationFailedAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties: 
      AlarmName: "MyApplicationTaskFailed"
      AlarmDescription: "My application has failed"
      Namespace: "AWS/Events"
      MetricName: "TriggeredRules"
      Period: 60
      Statistic: Minimum
      Threshold: "0"
      TreatMissingData: "ignore"
      ComparisonOperator: GreaterThanThreshold
      EvaluationPeriods: 1
      ActionsEnabled: true    
      AlarmActions:
        - !Sub "arn:aws:sns:eu-west-2:${AWS::AccountId}:AlertHigh"

  MyApplicationFailedRule:
    Type: AWS::Events::Rule
    Properties:
      Description: My Application has returned exit code 1
      Name: my-application-failure
      EventPattern: !Sub '{"detail-type": ["ECS Task State Change"],"source": ["aws.ecs"],"detail": {"containers": {"name": ["${AppName}"],"exitCode": [1],"lastStatus": ["STOPPED"]}}}'
      Targets: 
        - Arn: !Sub "arn:aws:sns:eu-west-2:${AWS::AccountId}:AlertHigh"
          Id: MyApplicationFailed
```