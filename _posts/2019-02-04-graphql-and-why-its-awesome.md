---
layout: post
title: '#GraphQL and why its awesome'
image: /assets/img/graphql/graphql.png
readtime: 6 minutes
tags: graphql
---

*TLDR - GraphQL is awesome*

I was quite late to the party with GraphQL, not really investing much learning time into it until recently.

It most definitely has its use cases, and here is how we use it at ditto music.

We have a whole host of backend internal services, which allow us to look up domain data. We have many apis as this is the approach we are taking to eventually split up the monolith database. 

At present though, we are dependent on a single huge monolith database which holds all data about pretty much everything about the business.

<amp-img src="/assets/img/graphql/monolith.png"
  width="852"
  height="874"
  layout="responsive">
</amp-img>


Since all of these apis are new, we need a way to expose some of this data publically, to be able to populate the new sales area we are working on. This is where GraphQL really helped us out!

To improve performance, we migrated all of the royalty data out of the monolith and into elasticsearch for many reasons, the main being the current sales area would slow down anything attached to the monolith when  querying a user with a massive amount of releases or sales.

<amp-img src="/assets/img/graphql/diagram.png"
  width="1616"
  height="1042"
  layout="responsive">
</amp-img>


We so far have only used the querying aspect of GraphQL, but we are able to describe our domain, and relationships between domain entities, without having to make changes to any of the backend apis. We are also futureproofing to some extent, the ability to query other data that may be needed.

All of a sudden, we are able to query data about our domain, without having to write custom endpoints, or join multiple datasets together explicitly

```
query {
  
  getReleasesByUserId(userId: 10000) {
    name
    
    label{
      name
    }
    
    assets{
      name
      assetType
    }
  }
}

```

Obviously, because of this approach, its important that we dont make all the data available to the user. We limited this by having the backend of the Sales UI make predefined calls to GraphQL, and also made sure that any queries to elasticsearch were predefined to not allow users to query each others data. 

The sales area that previously could take well over many seconds, sometimes even as many as 20, should be able to load in under a couple, well it will once it goes live to all users!

<amp-img src="/assets/img/graphql/iknowgraphql.jpeg"
  width="225"
  height="225"
  layout="responsive">
</amp-img>
