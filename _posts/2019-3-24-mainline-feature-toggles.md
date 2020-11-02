---
layout: post
title: Living in Utopia with Mainline Development
image: /assets/img/mainline/cover.png
readtime: 12 minutes
tags: features toggles mainline 
---

### I love a good merge conflict me

<amp-img src="/assets/img/mainline/steam.png"
  width="762"
  height="514"
  layout="responsive">
</amp-img>

...said no developer ever!! 

Yet its something that happens all the time. There are some great options out there, but the last 3 or 4 years or so, I have worked exclusively on the mainline using feature toggles.

The worst merge conflicts I've had to deal with are when a couple of developers have worked on conflicting code, and its only ever at most a couple days old.

<amp-img src="/assets/img/mainline/merge.png"
  width="1184"
  height="790"
  layout="responsive">
</amp-img>

### An example of how easy it is to get into a pickle

A team of developers are building your new product, you have an upcoming release sometime in the near future, and everything is being commited and merged into a branch called v1.1.0. 

You realise before release day, that theres a few bugs which need an emergency fix, so they get fixed on master. 

Suddenly you need to merge your changes up from master to v1.1.0, but there is weeks worth of work in that branch and also a massive refactor. 

A week has passed, just to merge the two different branches together, 4 devs have been unable to do any work, and the two devs working on the merge look really stressed out!! 

It's also added a few more days to test, and because of lack of confidence, one of the devs has suggested another manual test phase because they were unsure that the merge conflict may have had side effects on other code.

<amp-img src="/assets/img/mainline/panic.png"
  width="868"
  height="768"
  layout="responsive">
</amp-img>

The release is delayed, your competitor releases before you, and you business goes bust. because they take all your customers because their product is superior. Ok a bit dramatic, but who knows, it could happen!!

### What would you do?

- Fix in master, merge to the release branch?

- Fix in master and fix in the release branch seperately?

- Not get into this situation in the first place by always having your code base deployable, and using other techniques such as feature toggling?

### Its really a no brainer.

If you ask me, the answer will always be option 3. The faster you can release, the faster your customers can enjoy your product. The more the developers will enjoy developing more features, and less time QA'ing and finding / fixing bugs.

<amp-img src="/assets/img/mainline/nobrainer.png"
  width="2262"
  height="838"
  layout="responsive">
</amp-img>

On this note, its worth pondering whether a team of dedicated QAs to manually regression test changes over and over is worth it? 

Technology has progressed, and automated and integration tests will always be faster and most times more reliable than a human, and if you want your code to always be deployable to production at the drop of a hat with minimal side effects, its better in my opinion to invest in good devs with strong TDD skills / automation testing skills, and an attitude to just get stuck in and be T-Shaped.


### What is Continuous Integration?

Continuous Integration is the practice, in software engineering, of merging all developer working copies to a shared mainline several times a day. 

It means continuously integrating the code in one branch, not in multiple branches. (for those of you who need reminding twice).

<amp-img src="/assets/img/mainline/ci.png"
  width="1490"
  height="672"
  layout="responsive">
</amp-img>

### Mainline / Trunk Development

Everyone in the team who is working on the project will  commit to the single branch, in git, this is usually the master branch. 

Continuous Integration on the mainline branch guarantees that the branch is ready for deployment at any given point of time.

This means you can:
 
- Fix a bug without affecting any ongoing work
- Stop development on a feature because focus has changed without a period of refactoring (although you would always want the codebase to be as lean as can be)
- Not make your developers angry by having them fix merges!

### But how can you release half finished work into prod and there not be an issue?

One word. Feature Toggles (well two words).

<amp-img src="/assets/img/mainline/two-words.png"
  width="948"
  height="666"
  layout="responsive">
</amp-img>


Feature Toggles / Feature Switches allow you to turn on code paths from some kind of configuration. 

- An example is through a configuration file, or a service. Or if you want to really get fancy, an experimentation service, where you can have criteria select who has access to the feature.

### Hold on, this sounds too good to be true!!

Imagine letting 5% of your users test your amazing new feature before you roll it out to 100%. You could figure out actual impact before you annoy your userbase!

### Isnt this going to add a massive amount of complexity to an application?

That depends. How complex are you going to make it?

Some things to bear in mind is once a feature is completed, the toggle should be removed completely, this disolves confusion. 

You should treat the toggles like a branch too, the longer you leave it, the more ingrained into the application it becomes. Try to keep toggles in for as short time as possible. 

Use best development practices like dependency injection to provide two different concretions and use the toggle to choose between the two concretions.

### What does it feel like once you are there?

Utopia! 

<amp-img src="/assets/img/mainline/utopia.png"
  width="1480"
  height="626"
  layout="responsive">
</amp-img>



Imagine a world where you need a a quick fix that needs to be pushed to production. Never again will there be confusion on which branch to fix. 

Just think you can test your super awesome new feature that you expect would to revolutionize your business, only to find out it is a complete flop, and you find out waaaaaaaay before you dedicate a load of resource into building a gold plated soltion

How great would it be if you had a part of your site that sometimes couldn't function without a third party, and their api went down and you could just flip a switch, and everything is hunky-dory!?

Did I forget to mention you can also use this for A/B testing, and subject 50% of your users to one experience, and 50% to the other and compare which converted better?

### Its important to remind ourselves of what we are leaving behind here:

No more rolling back code, no more merging (or at least very complicated merging), more time spending developing the latest feature, no more trying to figure out which branch you should be working in.

### Takeaway points

One thing to remember, and one of the most important things to take away from this is toggles need to be short lived, keep toggles as few as possible. Adding too much complication through toggling is equaly, if not worse than having a load of branches!

<amp-img src="/assets/img/mainline/thumbs-up.png"
  width="1864"
  height="1188"
  layout="responsive">
</amp-img>
