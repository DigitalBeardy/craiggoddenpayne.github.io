---
layout: post
title: The pros and cons of using graphql instead of rest
image: /assets/img/graphql/graphql.png
readtime: 12 minutes
---

### Pros

Data Size - You can query for only the data you require, and you will be returned exactly that. This could be done in rest also, but it’s not a standard way of doing things e.g. `/products/12345?fields=name,price`

Protocol support - You can use graphql over other protocols than just http. A good example of this would be websockets, which graphql also has observable support.

Baked in validation - Validation of queries and mutations are built in, although you could say this is comparable to some of technologies used over rest services, such as ModelBinding and ModelValidation in aspnetcore.

Usability - Graphql can have much more simplified contracts than rest. Example of this would be that you only need to send the type e.g. query or mutation, rather than with rest where you need to send using a method (`GET/POST/PUT` etc.), the specific resource location and the payload. 

Single endpoint - In rest, it is cmmon to have to call multiple endpoints to get the data you need. with graphql you can do this in one query to one endpoint. Other content types exist to help with this, like hateos over rest, but they are (in my experience) a nightmare to maintain. You could argue that the single endpoint is also a negative, as you can easily apply caching rules in rest over particular endpoints (resources) with certain methods e.g. `GET`

Simplicity - You don’t ned in depth knowledge of http stack (although it’s more or less a prerequisit as a web developer these days). Also because rest over http has quirks, it is often difficult for experts to agree on what is correct within a rest service over http.

Simple architecture - Having graphql decouples your UI from individual services. (This is a massive advantage when you have multiple apis, authentication schemes, or apis that have a high change rate on a service as it reduces a lot of complexity and the UI needs to know very little about the server).

Subscrition support - You can subscribe for changes to data unlike rest which would require polling of a resource to get updates.

Introspection - although you can get similar tools such as swagger on top of a rest service, no documentation is really needed within graphql, and this can be disabled to help obfuscate a user from knowing your schema.

Scaling - You could again ague for and against this, as graphql could potentially call a service hundreds of times if not tuned well, but on the other hand, because graphql doesn't know about specific logic, you can stand as many instances as needed without having to worry about concurrency issues, similar to a well written rest service.

Quick tp get started - graphql is easy to design and amazing to consume. With rest, you have to go through the exercise of understanding the users needs before you can build the api, otherwise the shape of the data or domain may not be quite right. You can use the principles of design later in graphql as you can create a basic schema and then work out how to call the backend later.


### Cons

Error handling isn't so straightforward - Unlike rest, you won’t get a response status code e.g. 500 when something goes wrong. You would typically check the response errors for the reason, and if there are many, it can start to get complicated quickly.

Caching - (specifically caching at the web proxy level) isn’t as good as a rest implementation, as there’s usually a single endpoint for graphql. Some of this can be combatted with DataLoader (see below). 

Potential for performance issues - You have less control over the resources being retrieved in graphql, and although there are tools to combat this such as DataLoader which allow batching and caching, they are addons rather than being baked in. You also still need to make sure that the services behind your graphql instance are able to scale, and cope with the potential load that graphql will hit it with.

Maturity - graphql was only released (publicly) in 2015, although has been in development since 2012. Rest has been around since 2000, so is very mature, tried and tested.

Introspective - Introspecive is enabled by default, and anyone with access to the endpoint will be able to use introspective to play with your service

Exceptions - graphql is inferior to edge systems such as rest and therefore it can be very complex to work out where something goes wrong, or if an update partially succeeded.

Simplicity - Because the usage is so simple and easy to start working, it is a common mistake when "migrating" is to model the graphql schema against the schemas that exist in the apis they indend to call. This can expose functions that may not be needed, or can create unnecessary chattiness. This leads to bad design choices like stripping out data that is not needed data, rather than fetching just the data that is needed.

Security issues - The way the query context works means it is not recommended to insert your own authorization into graphql, as it is easily overwitten. By its nature, query context allows injecting of data which can easily be overwritten, although this is easily combatted by keeping authorization at the business level: `https://graphql.org/learn/authorization/`

Annoyances - circular relationships are easily created between objects, and can be exploited to crash the system without proper care. This can be overcome with query length limiting, query whitelisting (where you parameterise a list of approved queries) depth limiting, amount limiting or timeouts, although damage could already be done before some of these measures take place