# aerogel-mailer

A mail delivery module for aerogel applications.

## Usage


In your application's config.ru:
```ruby
require 'aerogel/core'
require 'aerogel/mailer' #

# define a new mailer named :test
Aerogel.mailer :test do |f, t|
  from f
  to t
  subject 'test'
  body 'hello'
end

# then send email message using this mailer:
Aerogel.email :test, 'from@domain.org', 'to@another.org'

run Aerogel::Application.load
```
