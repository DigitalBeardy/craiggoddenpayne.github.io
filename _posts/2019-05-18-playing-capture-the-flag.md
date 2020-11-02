---
layout: post
title: Playing capture the flag - coding challenges - sql injection 1
image: /assets/img/ringzer0/cover.png
readtime: 6 minutes
---

I recently have been playing some capture the flag games, I found a site called ringzer0 who host many different types of coding challenges.

It mentions on their site: 
`RingZer0 Team Online CTF` 

`RingZer0 Team's online CTF offers you tons of challenges designed to test and improve your hacking skills through hacking challenges. Register and get a flag for every challenge.`

I really wanted to test out some of the skills I have learned from completing some of the portswigger web security academy, built by Portswigger.

<amp-img src="/assets/img/ringzer0/portswigger-web-academy.png"
  width="807"
  height="404"
  layout="responsive">
</amp-img>

I read on the ringzer0 site, that the aim of the game is to collect the flag, which is a key which can be found by bypassing or figuring out the challenge.

### First challenge - Most basic SQLi pattern.

Being the first challenge in the set, I thought it was going to be really straightforward, and the best place to really start.

<amp-img src="/assets/img/ringzer0/challenge-1.png"
  width="775"
  height="389"
  layout="responsive">
</amp-img>

I tried logging in, just so I could see the functionality, and as expected there was a message saying incorrect username / password. Now it was time to play with the functionality. I loaded up burp suite and captured the login call and played it.

<amp-img src="/assets/img/ringzer0/challenge-1-request-1.png"
  width="1170"
  height="461"
  layout="responsive">
</amp-img>

I then started modifying the request to see if I could break it, which would signify that I somehow affected the outcome of the request, so I sent the request from the interceptor to the repeater, and then modified the parameters, my thinking being that maybe in the backend the system would be running a sql query something like:

```
SELECT username, password
FROM users
WHERE username=@username AND password=@password
```

So I changed the repeater query to terminate out of the query by adding a `'` into the username, this is a sql injection challenge afterall.

<amp-img src="/assets/img/ringzer0/challenge-1-request-2.png"
  width="1155"
  height="351"
  layout="responsive">
</amp-img>

Something strange happened, instead of wrong username / password I got a message showing `You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'password'' at line 1`

So I did the most basic thing possible, and just added an or statement at the end of the query parameter, and commented out the rest of the query like so:

```
username=username'+OR+1=1;/*&password=password
```

which only caused the request to hang and eventually return a 504 error. I think its because the multiline comment


<amp-img src="/assets/img/ringzer0/timeout.png"
  width="320"
  height="115"
  layout="responsive">
</amp-img>

So instead I tried it again and realised no, it was just the server returning that, so i tried it again and got the message `You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '/*' AND password = 'password'' at line 1`

I think commenting out the rest of the query must be causing the issue so i try and add some logic to be applied inline

```
username=username'+OR+'a'='a&password
```

which again showed wrong username / password, so I modified it slightly to

```
username=username&password=password'+OR+'a'='a
```

which completed the challenge

<amp-img src="/assets/img/ringzer0/challenge-1-request-3.png"
  width="1114"
  height="294"
  layout="responsive">
</amp-img>

The reason this worked must be because behind the scenes, the query must look like

```
SELECT username, password
FROM users
WHERE username='username' AND password='password';
```

and our modified query would have changed this to be something the below, which would have bypassed the password check.

```
SELECT username, password
FROM users
WHERE username='username' AND password='password' OR 'a' = 'a'
```