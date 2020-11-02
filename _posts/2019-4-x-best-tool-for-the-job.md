---
layout: post
title: Why it is important to use the best tool for the job.
image: /assets/img/tools/cover.png
readtime: 15 minutes
---

### As the saying goes, when you’re starting a software project, choose the best tool for the job!

This works so well, and for as long as I can remember, I have worked in environments where we are able to choose the right tool for the job by •council•. I emphasize council because its rare that a single person, will make the right decision.

There are many benefits of this, such as it motivates the employee to feel like they've had input, it allows them to expand their knowledge as as an individual and research what is currently out there, building self confidence and increasing their skill set and also adds variety to their day.

There are also important business impacts with evaluating these decisions. You’re not just choosing for yourself, you’re choosing for everyone and with that responsibility, technology decisions aren’t always so cut and dry. It's important not to bring in obscure technologies that are difficult to support, or hard to hire a replacement for if a developer leaves.

It's also important to do research and make sure the technology you are about to use isn't going to need to be completely rewritten within a few months time, because the framework is no longer supported, or a developer just wants to use the next best framework.

<amp-img src="/assets/img/tools/handyman.png"
  width="1400"
  height="736"
  layout="responsive">
</amp-img>


### Best ways to achieve this

I've seen this in many ways, from guidelines of what to use (not too strict, not too loose), to a tech radar, similar to the [thoughtworks tech radar](https://www.thoughtworks.com/radar). At Zuto we used this and it allowed developers from across different squads to be able to see what technology was being used around the business. This helped a lot in terms of seeing the various tech we were using, and the good and not so good things it was bringing. It's a great tool for when there are quite a few developers.

<amp-img src="/assets/img/tools/tech-radar.png"
  width="924"
  height="794"
  layout="responsive">
</amp-img>


### What are the impacts when this is taken away?

Being forced to use a tool that someone doesn't understand, or not giving them the chance to understand it, or them knowing about a technology that would work much better just annoys the employee, it stems creativity and productivity nosedives because the employee is now no longer as motivated.

This usually happens to your best developers, especially the ones that want to change the world and want to help solutionise and look at the over arching problem or feature, rather than just the very specific problem. They tend to have the most knowledge, the most drive and have the most impact on changing a business, because they usually are a more well rounded individual and have the businesses best interests at heart. They are most likely to embrace freedom of choice, and most likely to jump ship when they feel oppressed, leaving more subservient developers behind. 

<amp-img src="/assets/img/tools/motivation.png"
  width="1084"
  height="732"
  layout="responsive">
</amp-img>


### A situation that happened to me recently

Recently, I've been in a situation where I have gone from having the freedom and ability to choose what is best by council, to being told exactly what tech to use, from source control, to project management and what now is being investigated is CI/CD. Problems were solutionised for us, and we were treated as what could be classified as "code monkeys". (I hate that phrase too)

The decisions were made with, what I can only understand as lack of experience in technology and project management, and I think one of the main issues was the inability to not listen to people around them. This kind of micromanagement had a very negative on one of the best teams I have worked with, as you can imagine.

I completely understand when changes need to be made, but sometimes, its better to let the experts make the decisions they are paid to make.

<amp-img src="/assets/img/tools/micromanagement.png"
  width="784"
  height="444"
  layout="responsive">
</amp-img>


### What changed for us:

- We were told to use Jira instead of Trello
- No pairing where possible, and we were asked to duplicate tickets where pairing is involved (so they could be tracked as two work streams)
- We were moved from using Github as the source control to BitBucket
- We were advised to use the branch model, as they could be tracked better in Jira rather than using mainline, which affected CI/CD
- We had everything setup to benefit from continuous delivery, where we can release many times a day to a single release into production every 2 weeks (bearing in mind, the scope and complexity of the application was relatively straightforward)
- A very strict workflow which added dependency on pieces of work, i.e. Each stage would be approved by an "authoriser". Manual QA would be favoured over automated testing etc.
- Developers are soon to be removed from accessing QA and Production accounts. I still have no idea how they expect us to support the work we are producing
- We had evolved from scrum to #noestimates and breaking down work to equal sizes and instead were to to move back to "scrum" which was more like mini waterfall, and estimating 1 point as 1 day (It's been a long time since we have had to estimate with actual time values) 
- We no longer allowed to find the solutions to problems or help with feature definition. Tickets were instead solutionised for us, and we had to just build the code
- We were moved from Kanban to Scrum

As you can imagine, 6 employees (out of 9) left within a couple of months, and every decision was questioned with very vague answers such as "we are an atlassian company, we should be using all atlassian products". 

<amp-img src="/assets/img/tools/facepalm.png"
  width="1232"
  height="820"
  layout="responsive">
</amp-img>

### Some of the good decisions we made recently, and the tools we chose:

Dashboard, which displays graph and tabular summaries of artist royalty data. 
- We used elasticsearch to house the "big data" used for calculating artist royalties. This was instead of a mysql database, running on a very old version, very insecure, very unperformant, duplication everywhere and no normalisation.
- We used GraphQL to join this data to many of the new APIs which has been built to try and break up the nightmare of a database
- We needed a pie chart, a bar chart, and a map view and for these we did some research and chose Chart.js as it seemed to be a great choice based on experience, and a small spike of alternative technologies
- The dashboard had to be responsive, reacting to various changes and user actions. For this we used react, again dur to experience within the team and looking at general trends out there

A sales import process
- We used aspnetcore for the API, due to experience within the team
- The import process was only run a couple of times a week, so it seemed inappropriate to have something running continuously in AWS and consuming resources. We decided on Lambda for validation and processing
- In order to push the analytical data to elasticsearch, we utilised a long running task within ECS, which would transform the data and push into elastic.

### Final thoughts

The last few weeks have been very difficult. It's strange what stemming the ability to free thinking can do to its employees. I don't want to sound bitter towards Ditto, but I think the reasons the majority of the developers walked out was justified. 

We had a solution to fix all the majority of the problems for the business, (the problem being an import job which was littered with bugs, and took 8 hours to run and integrated into the monolith application which would take down the site on a regular basis. We managed to replace with a solution which took 4 minutes, was scalable and was the first stage for splitting the monolith), yet this work was brushed aside in favour of fixing the old solution, which will take weeks, which after a couple has already been proven for the new agency staff to be unable to make any significant performance improvements

In my resignation, I mentioned about having to distance myself from they to be able to maintain credibility as an engineer, and I stick by that. I put it down as a life lesson, and now I know what to signs to look for in a company I would choose to avoid for future employment!
