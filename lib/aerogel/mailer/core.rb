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
      Mail.deliver do
        from params[:from]
        to params[:to]
        subject params[:subject]
        body params[:body]
      end
    rescue => e
      raise "Mailer '#{name}' failed to deliver email: #{e}"
    end
    true
  end



end # module Aerogel::Mailer