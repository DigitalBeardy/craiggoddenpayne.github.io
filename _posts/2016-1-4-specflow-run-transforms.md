---
layout: post
title: Specflow Run Transforms
image: /assets/img/2016-1-4-specflow-run-transforms/smoketesting.jpg
readtime: 4 minutes
---

So I came across a problem today with SpecRun and concurrency issues.


It started after I wrote a suite of end to end smoke tests, that are to be run on our various testing environments to make sure we get some quick feedback after a deployment using team city.


I used SpecRun to execute my SpecFlow tests using Team City. I was using the transform stuff built into SpecRun to make sure that my configurations were all in tact, per environment. Everything looked good.


*I hadn't used SpecRun whilst developing the tests (as I was running my tests using NUnit and Resharpers Unit Test Runner).*


So I ran the tests, and after first few test runs all the tests passed, but then I started to get concurrency issues and access violations when the tests run. Lots of red error messages on my screen, the only feedback from SpecRun was mentioning that it couldn't access a file .config,bak


This was a bit weird as I was using SpecRun's build in configuration transformer, and everything so far just worked! I tried recreating the script that ran SpecRun on team city locally, and the same thing happened, occasionally I get the access violations. Weird.


I browsed the documentation and no where could I find anything about this, and after a quick google search, I managed to find another user with the exact same issue. The problem was the solution was on YouTube, and any deemed social media-ry website is blocked. So I loaded up the site on my phone and managed to reuse the fix.


So it turns out there's a secret node, not in the XSD I was given for SpecRun (The node called RelocateConfigurationFile) . It instructs SpecRun to rename the config file prior to running the tests. Since you can combine this with the TestThreadId, you can have multiple scenarios being run concurrently as each "session" will have a separate config file.


Here is the code I used to fix my concurrent issues. Hope this helps someone else in the future!


Here is some more information on the node in question: 
[github](https://github.com/gasparnagy/berp/blob/master/examples/gherkin/feature_files/RelocateConfigurationFile.feature)
