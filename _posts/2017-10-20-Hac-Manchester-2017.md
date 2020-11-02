---
layout: post
title: HacManchester 2017
image: /assets/img/2017-10-20-Hac-Manchester-2017/hackman.jpg
readtime: 7 minutes
---
GCHQ Winners, Hack Street's Back!

We entered the competition in 2016 and close very close to winning an award, but this year we won!!

The team was made up of me, Dave Mason and Tim Borrowdale.


https://www.hac100.com/


We decided to take on the GCHQ challenge, because it seemed the most interesting to us, the change was: "to develop a new way to send information to the emergency services. This could involve communicating data in a secure or anonymous way, verifying the received information is genuine or interpreting and analysing information so that it provides new insight."


We came up with a concept of a product called Beacon.


![raspberrypi](/assets/img/2017-10-20-Hac-Manchester-2017/raspberrypi.jpg)


It is a voice-activated device that listened for a particular keyword and notified the emergency services. There would be a web interface for the emergency services to track outstanding calls, and an app that received a push notification when it was triggered and allowed users to cancel the call.


We prototyped the device itself on a Raspberry Pi, running Raspbian.

We had a long-running process that listened for sound starting and ending, then created a WAV file. and uploaded AWS Lex when it captured. We used the speech-to-text functionality to return the sound converted to text, and if we matched on the keyword, we executed a Lambda function (written in node.js) that orchestrated the data storage and the push notification. It sent up meta information also such as the clientip, so that we could do geoip coordination to AWS API Gateway.


The web UI was written using react.js and used API Gateway to get outstanding calls and delete them. The app could also do the same, using the same API Gateway. The web UI is intended to be used as the police HQ for tracking and managing emergency requests.


![infrastructure](/assets/img/2017-10-20-Hac-Manchester-2017/beacon-infra.png)


Apart from some early struggles with the Pi itself, getting all these components talking to each other was actually fairly straight-forward. Lex in particular was very easy to get set up working for our simple use-case, and a shout out to the in-built testing framework in the AWS Lambda console, which made testing / debugging the function much easier than I thought it would be.


We also had to make a video to demonstrate our product. Please keep in mind we were VERY tired, had drank a LOT of coffee (and possibly a couple of beers at the free bar the night before), so cannot be held responsible for the quality or content of the following:


The Awards Ceremony
Having been awake for almost 40 hours, 25 of which were spent frantically coding, what we really needed was... more free food and alcohol! So off we went to the awards ceremony...


Hack Manchester is a great event that the organisers put their heart and soul into every year, and the awards ceremony is always fantastic (particularly if you like cheese jokes), and this years was no exception.


So when we were short-listed for the GCHQ prize, we suddenly felt like it was going to be last year all over again, until the winners were announced... Hack Street's Back! Here we are, collecting our prizes of an Apple TV 4K (64GB) and the much sought after GCHQ puzzle book:


![gchq](/assets/img/2017-10-20-Hac-Manchester-2017/gchq.png)


In the day-to-day as a developer, your time is spent (quite rightly) planning your work, writing unit tests, managing CI / CD pipelines, all in the name of quality and stability. Having 25 hours to hack something together (that with a bit of luck will work when you show the judges) is good for the soul. Also, getting outside our usual tech stack and trying out things like Raspberry Pi, node.js and various server-less AWS services was really exciting, and a great eye-opener.


If you're reading this and thinking about entering a team for Hack Manchester 2018, then I'd strongly recommend it. Though be warned, we'll be back defending our title...


![winners](/assets/img/2017-10-20-Hac-Manchester-2017/hacman-winners.jpg)