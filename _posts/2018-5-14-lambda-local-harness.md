---
layout: post
title: Library for testing an AWS lambda locally with C#
image: /assets/img/local-lambda-harness/cover.PNG
readtime: 4 minutes
---

Recently I've been working on a library that will allow you to run an AWS lambda locally, as you would within an API Gateway. This is really useful for testing as if it were a real lambda, and has helped me out massively!

It works by standing up a web server (kestrel) which will proxy the incoming request into an ApiGatewayRequest and forward onto the instance of your lambda, with the context sending output to the console.

### Setup

First of all, you will need to create a sperate project, to host the lambda, so create a new Console Application.

In the package manager console, install the library using the command `install-package lambda-local-harness`

In your console application you will want to new up the LambdaHost and Wait, similar to:

```
class Program
{
        static void Main(string[] args)
        {
            Ioc.IocSetup();
            var function = new Function(Ioc.Resolve<IApplicationValidator>(), new TelemetryClient());

            using (var host = new LambdaHost(function, nameof(Function.FullApplication), new Dictionary<string, string>()))
            {
                host.Wait();
            }
      }
}
```


Once setup and run, you can send requests to the lambda, and test your lambda, debugging support etc.

If you want more information, checkout the github repo:
[https://github.com/craiggoddenpayne/lambda-local-harness](https://github.com/craiggoddenpayne/lambda-local-harness)

<amp-img src="/assets/img/local-lambda-harness/console.PNG"
  width="642"
  height="183"
  layout="responsive">
</amp-img>
