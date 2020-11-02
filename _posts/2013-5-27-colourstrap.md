---
layout: post
title: Colourstrap/Colorstrap
image: /assets/img/2013-5-27-colourstrap/colour.png
readtime: 2 minutes
---

My new project! 

[colourstrap](https://github.com/craiggodden-payne/colourstrap) https://github.com/craiggodden-payne/colorstrap 

Eventually i will fork between the two, its just annoying that the american spelling and british spelling of colour have to differ!! I've started working on a project to enable easy colourisation of bootstrap without manually editing the css. so far, i have managed to strip out the hex colours (I'll have to look at the rgba values later) and can swap them out using javascript and regex. 

Its pretty straight forward, but has a few challenges. I have grouped the main colours into categories, Cold, Warm, Organic, Dry and Mono. I need to work out the differences using the hex values so that i can transform the colours. Another issue i realised i will come across is that if i swap out an organic colour, with a colour from cold, it could get overridden.

 What i think i need to do is replace within the source the colour based on a calculation, maybe comething like COLD+2000 where 2000 is the difference between the median colour and the current value within the temperature range. 
 
 So far i have managed to switch out the Cold for the Organic, a bit pointless, but at least its a proof of concept. Not only that, its written purely in javascript, so no server side processing :)