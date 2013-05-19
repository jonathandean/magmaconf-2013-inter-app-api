# Inter-Application Communication using Secure APIs

Jon Dean

[http://jonathandean.com](http://jonathandean.com)

[@jonathanedean](https://twitter.com/jonathanedean)

[#MagmaConf](https://twitter.com/search?q=%23MagmaConf&src=hash)



## What is an API?

Application Programming Interface


### What the heck does that mean?

Simply, a clearly defined (and hopefully documented) way for different pieces of software to communicate with one another



## What does an API look like?

It's up to you!



## Different types of APIs

- Code interfaces
- Web APIs
- Others



### APIs in code

The public methods in a Class define an API for how other code interacts with it

```ruby
class VeryImportantService
  def self.do_my_bidding
    set_up_some_stuff
    do_some_work
    build_the_output
  end

  private

  def set_up_some_stuff
    # ...
  
  def do_some_work
    # ...
  
  def build_the_output
    # ...
end
```


The API for ```VeryImportantService``` is the ```do_my_bidding``` method

_The private methods are NOT part of the API but part of the internal implementation_



## Web APIs

Generally a __Server__ application that exposes some data and/or functionality to be consumed by another __Client__ application



## RESTful Web APIs

_REST:_

*RE*presentational *S*tate *T*ransfer


### REST in Rails

Ruby on Rails encourages RESTful URLs as a best practice and should already feel familiar


### Key components of REST

- Stateless
- Cacheable
- Uniform interface
- Designed for use over HTTP
- Choice of data format


### Stateless

All of the information needed is part of the request. There's no need to store the state of anything between requests.


### Cacheable

Just like websites over HTTP, responses can generally be cached by the client to improve performance.


### Uniform interface

Clients and Servers have a uniform interface that simplifies architecture and design. Additionally, well-design RESTful APIs look familiar and similar to one another.


### Designed for HTTP

Uses familar HTTP verbs __GET__, __POST__, __PUT__, and __DELETE__

_The Word Wide Web itself is RESTful_


### Choice of data format

Most RESTful APIs use _JSON_ or _XML_ for formatting the data, but you can use whatever you want. (The Web uses HTML)



## Examples of public RESTful APIs

[Twitter REST API](https://dev.twitter.com/docs/api)

[Tumblr API](http://www.tumblr.com/docs/en/api/v2)



## What do I need an API for?

A few of the many reasons:

- Give others an interface to your product (Twitter and Tumblr APIs)
- Allow systems written in different languages to communicate
- Provide an abstraction layer for your own systems



## Real-world Problem at Stitch Fix

Two Rails applications that need to share functionality:

- An admin application that charges customers a styling fee when their items are shipped
- A customer-facing website that charges clients for the products they keep when they checkout


### ...AND

- A legacy admin application written in Django


### Shared functionality

- Charge the customer's credit card
- Log the response from the Payment Gateway
- Handle cases of payment failure



## Ways to share functionality between apps

- Create a gem containing a shared code library
- Set up a RESTful API service that all apps (including future ones) can use


### Pros of sharing code via a gem

- Easy
- Abstract the work via code-level APIs
- Can cost less money (no additional servers)
- No network latency
- No need to implement authentication


### Cons of sharing code via a gem

- Need to update and deploy all applications when the gem changes
- Internal improvements require a change in all applications using it
- Cannot easily add other languages to your systems. _(Our legacy app can't take advantage of new code!)_


### Pros of sharing code via an API service

- Internal changes have no affect on client applications
- Can independently scale the resource that deals with payments
- Can add clients in any language to your systems. _(We can update our legacy Django app to take advantage of better payment code)_
- Apps don't have to connect to the same data store


### Cons of sharing code via an API service

- More complex
- Costs money to run an additional application
- Network latency
- Handling timeouts and other service unavailability issues
- Also need to implement an authentication layer



## Concerns of an API Service

- Authentication
- Versioning
- Security


### Authentication

Ensure that only the allowed clients are able to connect to the service. For our private API the only allowed clients are our own apps.


### Versioning

Changes to the public API should be versioned. Older versions can be _depcrecated_ or disabled, depending on the change.


### Security

Ensure that all data sent between clients and servers are encrypted to prevent eavesdropping.
