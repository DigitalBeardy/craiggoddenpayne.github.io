---
layout: post
title: dotnet core code coverage using AltCover and ReportGenerator
image: /assets/img/altcover/cover.png
readtime: 10 minutes
tags: altcover reportgenerator code coverage dotnet core
---

[AltCover](https://github.com/SteveGilham/altcover/wiki/Usage) is awesome!!


### Code coverage for dotnet core

Some of the traditional code coverage tools for .Net have still not yet been ported for dotnetcore.

A while back, I was tasked in finding a code coverage tool to integrate into our build process. I found that with altcover, rather than hooking into the .net profiling API at run-time, it works by weaving the same sort of extra IL into the assemblies of interest ahead of execution. 

AltCover can be included as a NuGet package, or you can install it as a global tool, which is handy for say build agents. 

### How to install

Globally

```
dotnet tool install --global altcover.global
```

Project

```
dotnet add package AltCover
```

### How to run

```
dotnet test /p:AltCover=true
```

This will output a coverage.xml file in opencover format.

You can then run ReportGenerator on the coverage file to genetate a UI to visualise the data.

Here is a full example of the command we use, which we then include as a coverage report inside our build process.

```
dotnet test /p:AltCover=true /p:AltCoverXmlreport=".\coverage.xml" /p:AltCoverAssemblyFilter="NUnit" /p:AltCoverThreshold=80 /p:AltCoverAttributeFilter="ExcludeFromCodeCoverage"
reportgenerator -reports:src/SalesImportApi.Tests/coverage.xml -targetdir:./coverage
```

<amp-img src="/assets/img/altcover/report.png"
  width="2810"
  height="1564"
  layout="responsive">
</amp-img>