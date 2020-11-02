---
layout: post
title: Mobbing FizzBuzz
image: /assets/img/2015-10-12-mob-programming-fizz-buzz/fizz.jpg
readtime: 7 minutes
---

I was having a chat with another developer at work about mob programming (something that's a bit taboo where we work). I ran a developer huddle for our team and mobbed one of the code katas (FizzBuzz)

Mob programming Definition:

Mob programming is a software development approach where the whole team works on the same thing, at the same time, in the same space, and at the same computer. This is similar to pair programming where two people sit at the same computer and collaborate on the same code at the same time. With Mob Programming the collaboration is extended to everyone on the team, while still using a single computer for writing the code and inputting it into the code base

FizzBuzz Definition:

Imagine the scene. You are eleven years old, and in the five minutes before the end of the lesson, your Maths teacher decides he should make his class more "fun" by introducing a "game". He explains that he is going to point at each pupil in turn and ask them to say the next number in sequence, starting from one. The "fun" part is that if the number is divisible by three, you instead say "Fizz" and if it is divisible by five you say "Buzz". So now your maths teacher is pointing at all of your classmates in turn, and they happily shout "one!", "two!", "Fizz!", "four!", "Buzz!"... until he very deliberately points at you, fixing you with a steely gaze... time stands still, your mouth dries up, your palms become sweatier and sweatier until you finally manage to croak "Fizz!". Doom is avoided, and the pointing finger moves on.

So of course in order to avoid embarassment infront of your whole class, you have to get the full list printed out so you know what to say. Your class has about 33 pupils and he might go round three times before the bell rings for breaktime. Next maths lesson is on Thursday. Get coding!

Write a program that prints the numbers from 1 to 100. But for multiples of three print "Fizz" instead of the number and for the multiples of five print "Buzz". For numbers which are multiples of both three and five print "FizzBuzz?".


We only had an hour, so it had to be short. We thought it may be a chance to make sure we are all on the same page when it comes to TDD. Overall it was a lot of fun! It created a sense of shared achievement when we completed, and brought up a lot of debate about splitting up the responsibilities, and writing the smallest unit of work to be tested. I thought I was a bit OCD when it comes to red green refactor, but there's members of the team that are even more strict about it!

Here is our code, it took less than an hour, but was a chance for us to try something a bit different, and some of us learnt something from it, which is always a plus! Hopefully we will run more sessions like this, and maybe start to solve more complex issues in our codebase this way, and maybe using languages we are less familiar with.