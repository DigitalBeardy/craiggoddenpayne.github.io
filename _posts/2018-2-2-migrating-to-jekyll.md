---
layout: post
title: Why use jekyll as a blogging platform? 
image: /assets/img/2018-2-2-migrating-to-jekyll/jekyll.jpg
readtime: 11 minutes
---

I've finally got round to migrating my blog over to Jekyll, I must say I feel like its much better than blogger, (I can't believe I used it for so long!)


Jekyll takes your content written in Markdown, passes it through your templates and spits it out as a complete static website, ready to be served. GitHub Pages conveniently serves the website directly from your GitHub repository so that you don’t have to deal with any hosting.


But why use Jekyll over something dynamic such as wordpress?

- Jekyll is very minimal, and this eliminates a lot of complexity

- There is no database, which means its cheaper to run, and faster as pages are converted to static html, from markdown prior to publication.

- All the content is written in markdown, and uses specified templates and if served in github, works like a CMS.

- Jekyll is fast because it's just serving up static pages.

- Jekyll starts off with a basic setup, so you won't be including features that you aren’t using.

- You have complete control over the theme, and templating and its a very simple syntax, much more simple than creating a theme for say wordpress.

- Security is better, because there is no real backend, just some static pages.

- You can host in github, which is free, and you get the version control element for free!

The documentation on the jekyll website is great, and I had no problems at all following them and getting up and running locally in a few minutes

[Offical Site](https://jekyllrb.com/docs/quickstart/)

### Writing your first post

When you have a local copy of jekyll up and running, creating a blog post is as simple as creating a new markdown file, within the _posts directory using the format of year-month-day-name.md This will make the post available immediately. If you want to create a "draft" post, then you would need to to not include the date portion of the name.

One of the first things I did, was update the varibles I set on each post, so I can provide better information for my landing page, as well as each post.
The table at the top of each post allows you to set these variables e.g. mine consist of

```md
---
layout: post
title: Why use jekyll as a blogging platform? 
image: /assets/img/2018-2-2-migrating-to-jekyll/jekyll.jpg
readtime: 11 minutes
---
```

I use the image variable to show the image at the top of each post, and also as part of the landing page, to link to the blogpost. The same with title. I considered using one of the plugins, or a javascript library to show the reading time, but then I just thought i would manually include it, since its not too much work for me.

Take a look at the source for my site to get a better insight, or better still fork my site and build on top of it for yourself!

### Hosting on github

When you use github you are allowed one free user website which will live at http://yourusername.github.io.
If you place your unbuilt Jekyll blog on the master branch of your user repository, GitHub Pages will build the static website and serve it for you. You don’t have to worry about the build process at all.

Your website will be live within a few minutes, after checking in and pushing up.

One thing to note though, is if you are considering using github to host your blog, you won't be able to use any of the custom plugins. I found that the basic functionality is more than enough to get me going though!!
