require 'mail'

module Aerogel::Mailer

  def self.configure
    aerogel_delivery_method = Aerogel.config.mailer.delivery_method
    aerogel_delivery_options = Aerogel.config.mailer.delivery_options.raw || {}
    Mail.defaults do
      delivery_method aerogel_delivery_method, aerogel_delivery_options
    end
  end

  def self.register_mailer( mailer )
    @mailers ||= {}
    @mailers[mailer.name] = mailer
  end

  def self.mailers
    @mailers || {}
  end

  # Registers new mailer
  #
  def mailer( name, &block )
    Definition.new name, block
  end

  def email( name, *args )
    unless Aerogel::Mailer.mailers[name]
      raise ArgumentError.new "Mailer '#{name}' is not defined"
    end
    params = Aerogel::Mailer.mailers[name].eval( *args )
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
    # params,
  end


end # module Aerogel::Mailer