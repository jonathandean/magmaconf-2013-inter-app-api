# Inter-Application Communication using Secure APIs

Jon Dean

[http://jonathandean.com](http://jonathandean.com)

[@jonathanedean](https://twitter.com/jonathanedean)

[#MagmaConf](https://twitter.com/search?q=%23MagmaConf&src=hash)



## Presentation and sample code

[github.com/jonathandean/magmaconf-2013-inter-app-api](https://github.com/jonathandean/magmaconf-2013-inter-app-api)

Presentation is at [jonathandean.github.io/magmaconf-2013-inter-app-api](https://jonathandean.github.io/magmaconf-2013-inter-app-api)

Run locally by cloning and running ```grunt serve```. See [reveal.js](https://github.com/hakimel/reveal.js) for instructions.

Apps are at [magma-payments-service/](https://github.com/jonathandean/magmaconf-2013-inter-app-api/tree/master/magma-payments-service) and
[magma-client-app/](https://github.com/jonathandean/magmaconf-2013-inter-app-api/tree/master/magma-client-app)



## How many know these things already?

- Rails
- REST
- API



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

- Create a Customer in the Payment Gateway (Braintree)
- Charge the customer's credit card
- List previous transactions for a customer
- Log the response from the Payment Gateway
- Handle cases of payment failure
- etc.



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



## Payments Service Models

- Customer
- Transaction


## Payments Service Actions/Routes

- Create a Customer
- Update Customer information
- Create a Transaction
- Show all Transactions for a Customer
- Show details of a Specific Transaction


## RESTful Routes in Payments Service

_config/routes.rb_

```ruby
MagmaPaymentsService::Application.routes.draw do
  resources :customers, only: [:create, :update] do
    resources :transactions, only: [:create, :index, :show]
  end
end
```


## RESTful Routes in Payments Service

_rake routes_

```
GET  /customers/:customer_id/transactions     transactions#index
POST /customers/:customer_id/transactions     transactions#create
GET  /customers/:customer_id/transactions/:id transactions#show
POST /customers                               customers#create
PUT  /customers/:id                           customers#update
```


## Start with creating a customer

_app/controllers/customers_controller.rb_

```ruby
class CustomersController < ApplicationController
  def create
    # Need to send a hash of :id, :first_name, :last_name, :email
    result = Braintree::Customer.create({
      :id => params[:id],
      :first_name => params[:last_name],
      :last_name => params[:last_name],
      :email => params[:email]
    })
    # Build a hash we can send as JSON in the response
    resp = { success: result.success?, message: (result.message rescue '') }
    # Render JSON as the response
    respond_to do |format|
      format.json { render json: resp }
    end
  end
end
```


## Quick setup for Braintree

_config/initializers/braintree.rb_

```
Braintree::Configuration.environment = ENV['BRAINTREE_ENV'].to_sym
Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT_ID']
Braintree::Configuration.public_key = ENV['BRAINTREE_PUBLIC_KEY']
Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE_KEY']
```

Then go to https://www.braintreepayments.com/get-started to sign up and set some environment variables like

```
export BRAINTREE_ENV=sandbox
export BRAINTREE_MERCHANT_ID=[get your own!]
export BRAINTREE_PUBLIC_KEY=[get your own!]
export BRAINTREE_PRIVATE_KEY=[get your own!]
```


## Let's try

```
rails server
```

```
curl --data "id=1&first_name=Jon&last_name=Dean&email=jon@example.com" \
       http://localhost:3000/customers
```

_outputs_

```
{"success":true,"message":""}
```


## Let's try again

```
curl --data "id=1&first_name=Jon&last_name=Dean&email=jon@example.com" \
       http://localhost:3000/customers
```

_outputs_

```
{"success":false,"message":"Customer ID has already been taken."}
```


### Tip 

If you ever get something like _WARNING: Can't verify CSRF token authenticity_ then remove ```protect_from_forgery``` from ```ApplicationController```. We aren't submitting forms from our application to itself and so it will complain.



## Models in our Client App

- User
- Address
- (more we don't care about)


## Actions/Routes in our Client App

- Create a User
- Update a User
- Charge the User some money
- Show the times we charged a User
- Show details about a time we charged a User
- (more we don't care about)


## How can our Client App call the API?

__[httparty](https://github.com/jnunemaker/httparty)__ is the __curl__ of Ruby


## Create the customer from Client App

We want to create a customer in Braintree as soon as the User is created

_app/models/user.rb_

```ruby
class User < ActiveRecord::Base

  attr_accessible :name, :email
  after_create :create_payments_customer

  def create_payments_customer
    params = {
      id:         self.id,
      first_name: self.name.split(' ').first,
      last_name:  self.name.split(' ').last,
      email:      self.email
    }
    response = HTTParty.post('http://localhost:3000/customers.json', { body: params })
    answer = response.parsed_response
    puts "response success: #{answer['success']}"
    puts "response message: #{answer['message']}"
  end

end
```


## Let's try it!

```
rails console
```

```
1.9.3p194 :004 > user = User.create(name: "Jon Dean", email: "jon@example.com")
response success: true
response message: 
```


## Clean it up

Each environment will have a different URL

_config/environments/development.rb_

```ruby
MagmaClientApp::Application.configure do
  ...
  config.payments_base_uri = 'http://localhost:3000'
end
```

_app/services/payments_service.rb_

```ruby
class PaymentsService
  include HTTParty
  base_uri MagmaClientApp::Application.config.payments_base_uri
end
```

_app/models/user.rb_

```ruby
response = PaymentsService.post('/customers.json', { body: params })
```


## We can do better still

_app/services/payments_service.rb_

```ruby
class PaymentsService
  include HTTParty
  base_uri MagmaClientApp::Application.config.payments_base_uri

  def self.create_customer(user)
    params = {
      id:         user.id,
      first_name: user.name.split(' ').first,
      last_name:  user.name.split(' ').last,
      email:      user.email
    }
    response = self.post('/customers.json', { body: params })
    response.parsed_response
  end
end
```

_app/models/user.rb_

```ruby
def create_payments_customer
  answer = PaymentsService.create_customer(self)
  puts "response success: #{answer['success']}"
  puts "response message: #{answer['message']}"
end
```


## Concerns of an API Service
## Securing the Service

We can't have just anyone creating customers!

The Payments Service App needs a way to know that the client is accepted.


## Simple solution

A shared secret token!

```
> rake secret
0224651fc98de3a615243ebf75188ff430bdb2c1c983ab87614b3db2f4c7a167455354d6c0d2e7e788651bbead373bf0a9a166b12c63d47b48f060cdf759e16e
```


## Setting the token requirement in Payments Service App

_config/application.rb_

```ruby
module MagmaPaymentsService
  class Application < Rails::Application
    # NOTE: config.secret_token is used for cookie session data
    config.api_secret = '0224651fc98de3a615243ebf75188ff430bdb2c1c983ab87614b3db2f4c7a167455354d6c0d2e7e788651bbead373bf0a9a166b12c63d47b48f060cdf759e16e'
  end
end
```

_app/controllers/application_controller.rb_

```ruby
class ApplicationController < ActionController::Base

  before_filter :authenticate

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      token == MagmaPaymentsService::Application.config.api_secret
    end
  end
end
```


## Verify we secured the Service

Restart the Payments Service app and now you should get this if you try the API call again:

```
Started POST "/customers.json" for 127.0.0.1 at 2013-06-01 15:48:19 -0400
Processing by CustomersController#create as JSON
  Parameters: {"id"=>"38", "first_name"=>"Jon", "last_name"=>"Dean", "email"=>"jon@example.com"}
  Rendered text template (0.0ms)
Filter chain halted as :authenticate rendered or redirected
Completed 401 Unauthorized in 8ms (Views: 7.3ms | ActiveRecord: 0.0ms)
```


## Sending the token with the client request

_config/application.rb_

```ruby
module MagmaClientApp
  class Application < Rails::Application
    # NOTE: for both apps you are better off settings these as ENV vars
    config.payments_api_secret = '0224651fc98de3a615243ebf75188ff430bdb2c1c983ab87614b3db2f4c7a167455354d6c0d2e7e788651bbead373bf0a9a166b12c63d47b48f060cdf759e16e'
  end
end
```


## Sending the token (cont.)

_app/services/payments_service.rb_

```ruby
class PaymentsService
  include HTTParty
  base_uri MagmaClientApp::Application.config.payments_base_uri

  def self.create_customer(user)
    params = { ... }
    options = { body: params, headers: { "Authorization" => authorization_credentials }}
    response = self.post('/customers.json', options)
    response.parsed_response
  end

  private

  def self.authorization_credentials
    token = MagmaClientApp::Application.config.payments_api_secret
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
end
```


## Secure your secret token!

- Always use SSL in production
- Use a different token in each environment
- Move the token to ENV vars and out of source control



## Versioning

Sometimes (hopefully not often) the external API of your service will have to change.

Many of these changes don't have to force an immediate upgrade of all clients.


## A Simple change

We realized that our client apps just store one field for ```name``` for users and each of them is splitting the name for the benefit of Braintree. So we want to move
this logic into the service.

So our API will now accept just ```name``` for creating a customer instead of ```first_name``` and ```last_name```.


## Namespace for each version

Do this up front. Don't wait until you realize you need it.


## Deprecate vs. Discontinue

What if the new version is always mandatory?

You still want versioning.


## Why?

Because it's better to serve a message that the service refused the request rather than trying to run your code and things breaking unexpectedly. In both cases it's
broken, but only one of them will be easy to handle.

(Without versioning you may not even realize things are going wrong!)


## OK, so how?

Common approach: Modules and URL namespacing


## URL Namespacing

_config/routes.rb_

```ruby
MagmaPaymentsService::Application.routes.draw do
  namespace :v1 do
    resources :customers, only: [:create, :update] do
      resources :transactions, only: [:create, :index, :show]
    end
  do
end
```


## New URLs

```
rake routes
```

```
GET  /v1/customers/:customer_id/transactions     v1/transactions#index
POST /v1/customers/:customer_id/transactions     v1/transactions#create
GET  /v1/customers/:customer_id/transactions/:id v1/transactions#show
POST /v1/customers                               v1/customers#create
PUT  /v1/customers/:id                           v1/customers#update
```


## Move controllers into v1 directory

```
app/controllers/customers_controller.rb -> app/controllers/v1/customers_controller.rb
app/controllers/transactions_controller.rb -> app/controllers/v1/transactions_controller.rb
```


## Add them to the V1 module

_app/controllers/v1/customers_controller.rb_

```ruby
module V1
  class CustomersController < ApplicationController
    ...
  end
end
```


## Update the client to request V1

_app/services/payments_service.rb_

```ruby
class PaymentsService
  include HTTParty
  base_uri MagmaClientApp::Application.config.payments_base_uri
  VERSION = 'v1'

  def self.create_customer(user)
    params = { ... }
    options = { body: params, headers: { "Authorization" => authorization_credentials }}
    response = self.post("/#{VERSION}/customers.json", options)
    response.parsed_response
  end

  private

  def self.authorization_credentials
    token = MagmaClientApp::Application.config.payments_api_secret
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
end
```


## Creating a new version

- Add the new routes
- Add a new module
- Copy files from previous module to new one
- Make your changes in the new module


## Version 2 of the Payments Service API

_app/controllers/v2/customers_controller.rb_

```ruby
module V2
  class CustomersController < ApplicationController
    def create
      # Need to send a hash of :id, :name, :email
      result = Braintree::Customer.create({
        :id => params[:id],
        :first_name => params[:name].split(' ').first,
        :last_name => params[:name].split(' ').last,
        :email => params[:email]
      })
      resp = { success: result.success?, message: (result.message rescue '') }
      respond_to do |format|
        format.json { render json: resp }
      end
    end
  end
end
```


## Two available versions

Now clients can either send a ```first_name``` and ```last_name``` to ```/v1/customers``` or just a ```name``` to ```/v2/customers```. They have time to upgrade!


- Authentication
- Versioning
- Security


### Authentication

Ensure that only the allowed clients are able to connect to the service. For our private API the only allowed clients are our own apps.


### Versioning

Changes to the public API should be versioned. Older versions can be _depcrecated_ or disabled, depending on the change.


### Security

Ensure that all data sent between clients and servers are encrypted to prevent eavesdropping.
