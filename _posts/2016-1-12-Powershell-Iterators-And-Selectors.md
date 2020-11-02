---
layout: post
title: Powershell Iterators and Selectors
image: /assets/img/2016-1-12-Powershell-Iterators-And-Selectors/powershell.jpg
readtime: 8 minutes
---

I've used powershell quite a lot, I find it most useful at work when setting up build pipelines for team city, its really handy when creating build steps and you need team city to execute some custom functionality e.g. specrun. It's also good when trying to do some analysis on particular installed nuget packages. There are many uses, but these are main uses.


I find the syntax quite easy, I occasionally get caught out with projections, filtering and iterating, so I thought I'd write a quite cheat sheet post that may help others out there!


### Selectors

Select-Object is similar to linq select, it can be used for: 

- selecting specific object, or ranges from a collection of objects that contain specific properties
- selecting a given amount of elements from the beginning or end of a collection of objects
- selecting specific properties from objects

There are more things we can do with selectors, but this is just what I'll be covering.

To project a collection into a selector, you need to pipe it into the select-object cmdlet. You do this using the pipe character. e.g.

```powershell
Get-Process | Select-Object
```

You can then specify options to filter what we want e.g. we can select items from the array, but only elements 0,2,4 and 6


Or we can select the first 5 elements



Or we can can select all elements after the first 65



We can also create and rename an objects property, which can be useful when when the property name is not too descriptive and when we are passing from one cmdlet to another, and where the next cmdlet accepts and processes objects by Property Name.


The -property argument accepts a collection of objects, where you set the name and expression. The name is the name of the property, and expression is a script, whose result is the value.


Here is an example where we take a process from get-process cmdlet, and extract three of the properties, ProcessId, Name and CPU Amount.


```powershell
Get-Process | Select-Object -Property @{name = 'ProcessId'; expression = {$_.id}},@{nam
e = 'Name'; expression = {$_.ProcessName}},@{name='CPU amount';expression = {$_.CPU }} -First 5
```


Be mindful when using this, as when we select property names, it actually generates a new object of the same type with only those properties that we selected and strips out the rest. This may mean we remove a property, without realising, that we may need further down the chain.


### Iterating over Objects

Iterating allows us to perform an action on each element within a collection. There are ways of doing this using a for loop, or a while look, but we can also use a foreach loop (like in the examples below).


The ForEach-Object cmdlet takes a stream of objects from the pipeline and processes each and it uses less memory do to garbage control, as objects gets processed and they are passed thru the pipeline they get removed from memory.



The cmdlet takes 4 main parameters:
Begin <Script block> executed before processing all objects 
Process <Script block> executed per each object being processed 
End <Script block > to be executed after all objects have been processing all objects. 

To skip to the next object to be process in ForEach-Object the keyword Continue is used.
For exiting the loop inside of a ForEach-Object the break keyword is used.
