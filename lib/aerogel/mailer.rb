require 'aerogel/core'
require 'aerogel/mailer/version'
require 'aerogel/mailer/core'
require 'aerogel/mailer/definition'
require 'aerogel/mailer/error'


module Aerogel

  # register module's root folder
  register_path File.join( File.dirname(__FILE__), '..', '..' )

  # configure module
  on_load do |app|
    app.register Aerogel::Mailer
  end

end

