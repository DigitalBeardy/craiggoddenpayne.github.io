---
layout: post
title: Plugging an existing authenticated session into GraphQl
image: /assets/img/graphql-authenticated-session/cover.png
readtime: 3 minutes
tags: graphql apollo
---

I've recently started working with GraphQL, and I really like it! In work capacity, we have so far used it to talk to a few different services and databases. One of the advantages of GraphQL is the ability to query your data in anyway, which is a bit contradictory to this blog post.

We want to restrict certain queries to only be run and return data for the authenticated users session. I obviously don't want to mention too much about how we did this, or how our authentication works, but I will generalise how we did it.

<amp-img src="/assets/img/graphql-authenticated-session/padlock.png"
  width="666"
  height="712"
  layout="responsive">
</amp-img>


In it's simplist form, once a session had been logged in, we can fetch the session from the backend using a session id against a database of authenticated sessions. We're not going to handle authenticating sessions, that is handled elsewhere in the stack.


The GraphQL module we are using, is based upon ApolloServerExpress within node, which after trying a few alternatives, we quite liked. In order to allow graphql to pull the session id from the cookie, I needed to allow access for the request context within apollo, which meant passing in the expresss req object as a context. 

Also its worth mentioning, that by default, express does not have good built in support for cookies, so I included the npm module `cookie-parser` and added it to the middleware to make sure the cookies are put in the request pipeline.

Here is an example of the initial setup:

```
import { schema } from '../schema/schema';
import { ApolloServer }  from 'apollo-server-express';
import express from 'express';
import cookieParser from 'cookie-parser';
const server = new ApolloServer({ schema, context: ({ req }) => ({ req: req })});
const app = express();
server.applyMiddleware({ app, "graphql" });
const port = 80;
app.listen({ port }, () =>
    console.log(`🚀 Server ready at http://localhost:${port}/`),
);
```

<amp-img src="/assets/img/graphql-authenticated-session/ghraphql-apollo.png"
  width="978"
  height="612"
  layout="responsive">
</amp-img>


Once all the setup was done, I started by creating a GraphQL type to allow us to translate the SessionId into a UserId. 

I am going to use an instance of an AuthenticatedUserSessionService, which will lookup the user id, from the session id from the cookie. 


```
import { GraphQLInt, GraphQLObjectType } from 'graphql';
const AuthenticatedUserSession = new GraphQLObjectType({
    name: 'AuthenticatedUserSession',
    description: 'An authenticated user session',
    fields: () => ({
        userId: {
            type: GraphQLInt,
            resolve: authenticatedUser => authenticatedUser.userId,
        }
    })
});

export {
    AuthenticatedUserSession
};
```


Then I need to setup the schema, so that I can resolve the data. As you can see, I pass `context.req.cookies.SESSIONID` to my AuthenticationSessionService, which will resolve the UserId of the authenticated session.

```
import { graphql } from 'graphql-compose';
import { GraphQLString} from "graphql";
import {AuthenticatedUserSession} from "./types/authenticated-user-session/authenticated-user-session";
import {AuthenticatedUserSessionService} from "../services/authenticated-user-session/authenticated-user-session";

const { GraphQLSchema, GraphQLObjectType } = graphql;
const schema = new GraphQLSchema({
    query: new GraphQLObjectType({
        name: 'Query',
        fields: {
            getAuthenticatedUserSession: {
                type: AuthenticatedUserSession,
                args: { sessionId: {type:GraphQLString} },
                resolve: (root, args, context) => AuthenticatedUserSessionService.GetAuthenticatedUserSession(context.req.cookies.SESSIONID)
            }
        },
    }),
});

export default schema;
```

Now all the groundwork is down to resolve the UserId from the SessionId cookie using the AuthenticationService, it can now be used in place of any of the queries, which pass a userId in to query, which in turn will secure the service, and only allow the signed in user to access his own data.

<amp-img src="/assets/img/graphql-authenticated-session/tunnel.png"
  width="974"
  height="564"
  layout="responsive">
</amp-img>
