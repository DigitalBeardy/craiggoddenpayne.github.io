---
layout: post
title: JS13k coding competition | Agent XIII
image: /assets/img/js13k-competition/agent13.jpg
readtime: 8 minutes
---

This should be fun... there's a competition running at the moment (ending 13th Sept) to create a full javascript / Html5 game that is under 13k in size (minified)

[Js13kGames](http://js13kgames.com/)

Since i haven't had much exposure to Html5 canvas etc. it will be a good chance to try a few things out!

I'm thinking of having some sort of strategy game. At the moment i'm just getting the Game Runner logic in place, its already proving to be not too easy, without using 3rd party code!


Here is what I have done so far: Its coming in at about 7kb Zipped. I think i should be able to make the 13k limit, I just need to learn how to draw images using lines and rects, that should save me some kb, so far i have one 100x100px png image (weighing in at 2.6kb, if i add any more its going to eat up all my code space!!)

<amp-img src="/assets/img/js13k-competition/ingame.png"
  width="629"
  height="474"
  layout="responsive">
</amp-img>


I really like the space effect, its basically 520 random generated points on a 2d plane, I iterate through each point but also iterate a for(int i=0; i < 5; i++) then modulus the index of the point. I move each point 2 px to the left. This creates the illusion of layers of stars each layer moving at a different speed. Its pretty cool, i haven't done anything like it before!!

I just noticed the images dont load, oh well ill upload a working copy once i do some more on the game

Update - an updated version of the game so far: 20/08/2012 Not too far from completion!

[Github](https://github.com/craiggoddenpayne/AgentXIII)
[Offical Entry](http://js13kgames.com/entries/agent-xiii)


So i finally to round to finishing my 13k game, its not too fancy, just simple, but I like simple games :)

It really surprised me that I have spent many an evening working on random ideas for android games etc. (I've probably worked on over 50) and never finished one [ Except my POC Triple Triad Card List ], yet with this 13k game I managed to complete in a couple of nights! Maybe I should start playing around with html5 and javascript more, its just soooooo easy to get everything up and running, and i find debugging the code much nicer using firebug than using eclipse (for android)


And I guess knowing more and more about javascript can only be a bonus, as it seems like that's the way we are headed! Javascript is not a language i have ever officially studied, i just picked it up as I went along because i needed more functionality than html only supplied.


Classic example: today i realised that from a function, you can get all arguments passed in, but in array form by using the arguments object. I never knew this until today! Its scary how something simple like that can catch you out if you don't know a language inside out. I guess it also shows that someone can use complicated frameworks, test suites (jasmine etc.) yet not know something relatively basic. I guess you never really need to know something until you need to use it to solve a problem!!

...Guess it's time i got the textbooks out!!