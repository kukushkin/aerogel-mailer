require 'mail'

module Aerogel::Mailer

  # Configures module Aerogel::Mailer
  #
  def self.registered(app)
    aerogel_delivery_method = Aerogel.config.mailer.delivery_method
    aerogel_delivery_options = Aerogel.config.mailer.delivery_options.raw || {}
    Mail.defaults do
      delivery_method aerogel_delivery_method, aerogel_delivery_options
    end

    # load mailers
    Aerogel::require_resources( :app, "mailers/**/*.rb" )

    # register reloader
    setup_reloader(app) if Aerogel.config.aerogel.reloader?

  end

  # Registers new mailer
  #
  def mailer( name, &block )
    Definition.new name, block
  end

  # Deliver email using mailer specified by +name+
  #
  def email( name, *args )
    mailer = Aerogel::Mailer::Definition.mailers[name.to_sym]
    unless mailer
      raise ArgumentError.new "Mailer '#{name}' is not defined"
    end
    params = mailer.compile( *args )
    puts "** sending mail: #{params}"
    begin
      message = Mail.new do
        from params[:from]
        to params[:to]
        subject params[:subject]
        text_part do
          content_type 'text/plain; charset=UTF-8'
          body params[:body][:text]
        end if params[:body][:text]
        html_part do
          content_type 'text/html; charset=UTF-8'
          body params[:body][:html]
        end if params[:body][:html]
      end
      message.charset = "UTF-8"
      message.deliver
    rescue StandardError => e
      raise Aerogel::Mailer::Error.new "Mailer '#{name}' failed to deliver email: #{e}"
    end
    true
  end

private

  # Sets up reloader
  #
  def self.setup_reloader( app )
    app.use Aerogel::Reloader, ->{ Aerogel.get_resource_list( :app, "mailers/**/*.rb" ) } do |files|
      # reset mailers
      Definition.mailers.clear

      # load mailers
      files.each do |filename|
        Aerogel.require_into( Aerogel::Application, filename )
      end
    end
  end



end # module Aerogel::Mailer