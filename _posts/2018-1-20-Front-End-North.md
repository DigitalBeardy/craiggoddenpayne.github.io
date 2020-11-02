---
layout: post
title: Front End North Conference 2018
image: /assets/img/front-end-north/frontendnorth.png
readtime: 13 minutes
---
I went for a day trip to sheffield to attend the FrontEndNorthConference


In summary, it looks like we are already doing what the rest of the industry suggests as best practices, although there were some interesting things I learned whilst there.

<amp-img src="/assets/img/front-end-north/speakers.png"
  width="400"
  height="357"
  layout="responsive">
</amp-img>


The first talk was all about colour, and styling, I feel like I learned a lot about accessibility, it's not really something  I have had much experience at all in, in my career so far.


<amp-img src="/assets/img/front-end-north/colours.jpg"
  width="320"
  height="247"
  layout="responsive">
</amp-img>



The main thing I took away is that it's easy to exclude people who use ScreenReaders and have ColourBlindness by using bad design and colour choices

As a guide, we should have color contrast ratio as 3:1 for non-decorative text, sized larger than 18 point or larger than 14 point if bold. Text smaller than that should meet a contrast ratio of at least 4.5:1.

The speaker also went into detail about using the built in chrome developer accessibility tools checker (which is something I never really looked at before)
[Chrome Accessibility Tools](https://chrome.google.com/webstore/detail/accessibility-developer-t/fpkknkljclfencbdbgkenhalefipecmb/reviews?hl=en)

<amp-img src="/assets/img/front-end-north/wcag.png"
  width="206"
  height="104"
  layout="responsive">
</amp-img>


She also mentioned the Web Content Accessibilitiy Guidelines, which is something I should probably read up more on.
[WCAG](http://www.w3.org/TR/WCAG20/)


It has recommendations such as content should be distinguishable and requires we make it easier for users to see and hear content including separating foreground from background.
Another useful tool to use is colourblind filters, which will show what your site looks like to a user who is colourblind.
[ColourFilter](https://www.toptal.com/designers/colorfilter)

<amp-img src="/assets/img/front-end-north/styleguide.png"
  width="320"
  height="179"
  layout="responsive">
</amp-img>


The talks then shifted towards the importance of using a styleguide for consistency across your site.
A good example of a styleguide is
[Buffer Styleguide](https://buffer.com/style-guide)

This looks very similar to our styleguide (although it seems a bit easier to navigate around than our styleguide).
[Zuto Styleguide](https://styleguide.zuto.com/)

Another cool tool that was mentioned was a style guide generator page, which you can specify a URL and it will dynamically build a simple styleguide, based on the page, although after trying this out, it’s very basic.

[Stylify Me](http://stylifyme.com/) - Stylify Me was created to help designers quickly gain an overview of the style guide of a site, including colours, fonts, sizing and spacing.


<amp-img src="/assets/img/front-end-north/zombie.jpg"
  width="190"
  height="320"
  layout="responsive">
</amp-img>


The next speakers was a bit obsessed with zombies!
[SarahMoster](https://github.com/sarahmonster?tab=repositories)

She created another styleguide template that seemed cool
[Zombie Styleguide](https://github.com/sarahmonster/zombie-style-guide)

She spoke about a tool she created, which allows you to export a react application into sketch, which seemed really cool, I need to look more at her github! She also spoke about a style guide template she has used for react dev, which doubles as a react development environment, in a living styleguide

[Styleguidist](https://github.com/styleguidist/react-styleguidist)
Looks pretty cool

<amp-img src="/assets/img/front-end-north/offline-first.jpg"
  width="638"
  height="359"
  layout="responsive">
</amp-img>


The next speaker talked about the importance of designing sites from an offline perspective. This is a movement that has been taking off recently. Offlinefirst.org

By offline first, we mean we should still be able to use web apps with no internet connection (although I think this is mostly for app developers using a web view, but there are some things we can still take. The speaker also talked a lot about Progressive Web Apps

<amp-img src="/assets/img/front-end-north/pouchdb.png"
  width="320"
  height="180"
  layout="responsive">
</amp-img>


The speaker uses a tech called PouchDb, which will atomatically sync back with CouchDb (or other compatible noSql database server). She mentioned Couch dB has best replication compared to other databases. Again this looked more related to mobile apps, but I guess you could do something similar on websites.

Basically would mean a user fills something in, or submits some data, and the data is stored (I’m guessing in local storage) until internet connectivity resumes, and then the data is synced with couchDb. She showed an example, which did actually seem to work quite well.
[Shopping List](https://github.com/lornajane/robust-shopping-list)

The speaker did talk a lot about databases, and looking around, people started to look a bit bored.

The speaker then spoke about different tools she used for testing http stuff and wrote a pretty good article on it, which include some slides that can be downloaded.
[Http Tools Roundup](https://lornajane.net/posts/2017/http-tools-roundup) - At a conference a few days ago, I put up a slide with a few of my favourite tools on it. I got some brilliant additional recommendations in return from twitter so I thought I’d collect them.

There are a lot of offline first tools, but this one stood out, mostly because of the name
[Hood.ie](http://hood.ie) - The Offline First Javascript Backend

A fast, simple and self-hosted backend as a service for your (web) apps, Open Source and free. No need to write server-side code or database schemas. Makes building offline-capable software a breeze.

<amp-img src="/assets/img/front-end-north/validation.jpg"
  width="320"
  height="160"
  layout="responsive">
</amp-img>


The next speaker focused on why we are doing validation wrong, and about how validation and getting it right is just really hard (which we all know!)
[Inline Validation in Web Forms](https://alistapart.com/article/inline-validation-in-web-forms)


Web forms don’t have to be irritating, and your inline validation choices don’t have to be based on wild guesses. In his examination of inline form validation options, Luke Wroblewski offers that rarest of beasts: actual data about which things make people smile and which make them want to stab your website with a fork.

He has worked on a project called Conferize form, which he aims to make open source very soon.
It looked cool, but didn’t seem to solve all the issues easily.

A few things we don’t do, but make a lot of sense is
Don't enforce unnecessary rules where the user knows they are right
users know their own name
users know their own Telephone number
etc.

I guess this isn’t very practical in a scenario like financial services though!

<amp-img src="/assets/img/front-end-north/reactive-programming.jpg"
  width="640"
  height="285"
  layout="responsive">
</amp-img>


The next speaker spoke about Reactive Programming, and the stuff this guy writes is really cool

[Victory Chart](https://formidable.com/open-source/victory/docs/victory-chart/)


He provides react charts that are super simple to implement and are all open source!
He even has a graph building tool for the CLI, (victory cli)

[Gatsby](https://Gatsbyjs.org)


He wrote a pdf viewer in react, its cool

[React Pdf](https://github.com/nnarhinen/react-pdf)

react-pdf - React component for showing pdf documents


He also created a better webpack cli tool, which looks amazing, and something i'd like to try out in my day to day work.

[Webpack Dashboard](https://github.com/FormidableLabs/webpack-dashboard) - webpack-dashboard - A CLI dashboard for webpack dev server

<amp-img src="/assets/img/front-end-north/critical-css.png"
  width="300"
  height="225"
  layout="responsive">
</amp-img>


The next speaker talked about critical css

He spoke a bit about BEM as well as Atomic Design - [BEM & Atomic Design](https://www.lullabot.com/articles/bem-atomic-design-a-css-architecture-worth-loving)

Lullabot - Strategy, Design, Development

BEM & Atomic Design: A CSS Architecture Worth Loving

Using Pattern Lab and BEM on a project I stumbled upon a great way of structuring CSS, better naming, and better a developer experience.

[BEM](http://getbem.com)

BEM — Block Element Modifier is a methodology, that helps you to achieve reusable components and code sharing in the front-end.


What they aimed to achieve was to get all the critical content, within the first hit from the web server.

Congestion window 14k try to get all content on the very first hit. Prioritise critical content is what Google call it


You can store the fact you got critical css in a cookie so that it doesn't need to Fetch on other pages

Theres a project that helps to automate this called Critical css by filament group

[criticalCSS](https://github.com/filamentgroup/criticalCSS/blob/master/README.md)

This basically finds the Above the Fold CSS for your page, and outputs it into a file. You then need to look at how you render the rest of the page, which is where it gets messy.


Overall a good conference and great food!!

<amp-img src="/assets/img/front-end-north/food.jpg"
  width="612"
  height="417"
  layout="responsive">
</amp-img>