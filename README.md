# aerogel-mailer

A mail delivery module for aerogel applications.

## Usage

```ruby
# config.ru
require 'aerogel/core'
require 'aerogel/mailer'

run Aerogel::Application.load
```

```ruby
# app/mailers/my-test-mailer.rb
# define mailer:
class Aerogel::Application
    mailer :test do |f, t|
      from f
      to t
      subject 'test'
      body 'hello'
    end
end
```

```ruby
# app/routes/my-test-route.rb
# send mail from route handler:
class Aerogel::Application
    get "/test-mail" do
        email :test, 'from@domain.org', 'to@another.org'
    end
end
```
