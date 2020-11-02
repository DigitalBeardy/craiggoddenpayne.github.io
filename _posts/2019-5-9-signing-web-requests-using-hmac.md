---
layout: post
title: Understanding HMAC authentication and applying it to HTTP
image: /assets/img/hmac/cover1.png
readtime: 8 minutes
---

I have been reading up on hash-based message authentication code (HMAC), and how amazon use it 
to secure their apis.

### Why HMAC?

The idea behind HMAC is to generate a cryptographic hash of some data, using a secret key that the 
client and server both know. The hash generated can then be used by the other party to check the 
authenticity of the user by performing the same check and comparing the hash, but without both 
parties revealing the key that was used to sign.

It's not so much about hiding the contents of a message, it's more about integrity and 
proving the user that sent the request must have the same key.

For clarity, it's worth pointing out that a hash of the same message, hashed with different keys 
will generate a completely different value, and intercepting a messaged signed by the same user 
key, but for different messages will also generate a completly different hash, so its 
theoretically impossible to derive the original key by capturing messages or modifying the request 
by using say a man in the middle attack.

<amp-img src="/assets/img/hmac/hacker.png"
  width="696"
  height="320"
  layout="responsive">
</amp-img>

### Lets try it out using a HTTP Request

In order to generate a signature hash from a request, a canonical standardised version of the 
request must be created so that the same can be performed on the server. 

Amazon do this by turning the request into a string in the following format before hashing 
the string.

According to their documentation, they use this format:

- RequestType
- Domain
- URI
- Sorted string of parameters in property=value format

There isn't a standard way to do this, so technically as long as the client and server generate 
a canonicalised version of a request the same way, then we should be able to use it. 

Here's a canonicalised string I want to use for my example (similar to how amazon do it)

```
GET
craig.goddenpayne.co.uk
/signing-web-requests-using-hmac
SomeHeader=Value&UserId=12345
```

The Client knows that he is user `12345` (PublicKey) and has a (PrivateKey) of 
`Craig's-Secret-Key` 

Similarly, the Server knows that user `12345` (PublicKey) will sign requests using the 
(PrivateKey) `Craig's-Secret-Key`


I can then hash my message using SHA256 with my PrivateKey, and it would generate a 
signature such as

```
13eaaefdfcfb6a66f6d1df27a6458e8925c9f3a4c9480029a60443fad0d4fba9
```

The signature can then be appended to my request, and now the request I am 
sending contains the UserId (PublicKey) and the Signature (Canonical message hashed with PrivateKey)

<amp-img src="/assets/img/hmac/hash.png"
  width="594"
  height="212"
  layout="responsive">
</amp-img>


### Lets hit the server

```
GET https://craig.goddenpayne.co.uk/signing-web-requests-using-hmac?SomeHeader=Value&UserId=12345&Signature=13eaaefdfcfb6a66f6d1df27a6458e8925c9f3a4c9480029a60443fad0d4fba9
```

Its now the job of the server now is do pretty much the same thing to make sure the hash matches.

The server will intepret the request, remove the Signature and creates the canonicalised version of the request

```
GET
craig.goddenpayne.co.uk
/signing-web-requests-using-hmac
SomeHeader=Value&UserId=12345
```

The user is looked up using the PublicKey (UserId) and the PrivateKey is used to generate the 
hash the same way.

If the hash signature matches the signature parameter passed to the server from the client, 
it can then verify that the request was signed by the same PrivateKey and therefore the request 
can be considered authentic.

<amp-img src="/assets/img/hmac/hmac-integrity.png"
  width="570"
  height="246"
  layout="responsive">
</amp-img>
