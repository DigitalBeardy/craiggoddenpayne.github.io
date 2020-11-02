---
layout: post
title: Jade server for node js
image: /assets/img/2013-3-15-jade-server/jade.png
readtime: 6 minutes
---

I have been playing around with Node.js again, and have create a Jade web server.

Jade is a html templating engine similar to haml, that allow you to write html without all the extra syntax

e.g.

Valid Jade markup:

```jade
html
 head
 body
  div Hello World
```

The node module I have created is quite simple, it defaults to index.html if a template is not specified. templates can be loaded by using the query string key 'page' e.g. http://localhost:8080?page=about This will translate to about.jade template on disk.

I need to add support for loading local variables, i could do this using query string, but its not practical. maybe by using a post request? who knows! I need more of a think.

Here is the module i wrote: Dependencies - http,jade,fs,url

```js
var http = require('http');
var jade = require('jade');
var fs = require('fs');
var url = require('url') ;
var options = {pretty:true};

http.createServer(function (req, res) {
 var query = url.parse(req.url, true).query;
 console.log(query);

 if(!query || !query.page) {
  //Show Index Page
  fs.readFile("index.html", function read(err, data) {
   if (err) console.log(err);
   res.writeHead(200, {'content-type': 'text/html'});
   res.end(data);
  });
 }else{
  var template = query.page + ".jade";
  fs.readFile(template, function read(err, data) {
   if (err) console.log(err);

   var markup = jade.compile(data, options)({});
   res.writeHead(200, {'content-type': 'text/html'});
   res.end(markup);
  });
 }

}).listen(8080);
```
