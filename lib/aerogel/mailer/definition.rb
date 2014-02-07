module Aerogel::Mailer
class Definition

  include Aerogel::Render::Scope

  attr_accessor :name, :blk, :params

  DEFAULT_LAYOUT = "mailer"

  def initialize( name, blk )
    self.name = name.to_sym
    self.params = {}
    self.blk = blk

    self.class.register_mailer( self )
  end

  def from( str )
    params[:from] = str
  end

  def to( str )
    params[:to] = str
  end

  def subject( str )
    params[:subject] = str
  end

  # Sets layout name for text/plain and text/html layouts
  # or disables layout for message body templates.
  #
  # Example
  #   layout false # disables layout for text and html message templates
  #   layout 'mailer-admin' # sets layouts to 'views/layouts/mailer-admin.text.erb'
  #                        # and 'views/layouts/mailer-admin.html.erb'
  #
  def layout( name )
    params[:layout] = name
  end

  # Sets message body. Multiple calls to #body are allowed,
  # e.g. for setting  plain text part and html part separately.
  #
  # If message body is set via call to #body, existing mailer templates
  # and layout will be ignored.
  #
  # +args+ can be a String, which sets the text/plain message body
  # or a Hash.
  #
  # Example:
  #   body "This is a plain text message"
  #   body html: "This is a HTML only message"
  #   body text: "This is a plain text", html: "and <b>HTML</b> message"
  #
  def body( args )
    params[:body] ||= {}
    if args.is_a? String
      params[:body][:text] = args
    elsif args.is_a? Hash
      params[:body][:html] = args[:html] if args.include? :html
      params[:body][:text] = args[:text] if args.include? :text
    else
      raise ArgumentError.new "Invalid argument #{args.class} to #body"
    end
  end

  # Sets local variables to be passed to template. Multiple calls to #locals
  # are allowed, variables passed this way will be merged into one set before
  # passing to a template.
  #
  # Example:
  #   locals user: current_user, url: url
  #   locals order: order
  #
  def locals( args )
    params[:locals] ||= {}
    params[:locals].merge! args
  end

  def compile( *args )
    unless args.size == blk.arity
      raise Aerogel::Mailer::Error.new("wrong number of arguments for mailer '#{name}': #{args.size} for #{blk.arity}")
    end
    @self_before_instance_eval = eval "self", blk.binding
    params.clear
    instance_exec( *args, &blk )
    params[:from] ||= config.mailer.default_from
    if params[:from].nil?
      raise Aerogel::Mailer::Error.new("'from' address is not set for mailer '#{name}'")
    end
    render_body
    params
  end

  def method_missing( method, *args, &block )
    @self_before_instance_eval.send method, *args, &block
  end

  def self.register_mailer( mailer )
    @mailers ||= {}
    @mailers[mailer.name] = mailer
  end

  def self.mailers
    @mailers || {}
  end

private

  class TemplateNameCache
    # Returns template file name, use cached file name if possible.
    #
    def self.fetch( filename )
      @cache ||= {} # reset if reload templates is used
      return @cache[filename] unless @cache[filename].nil?
      if Aerogel.get_resource( :views, filename+".erb" )
        @cache[filename] = filename.to_sym
      else
        @cache[filename] = false # template not found
      end
      @cache[filename]
    end

    def self.clear
      @cache = {}
    end
  end # class TemplateNameCache

  # Renders message body using filled params.
  # Stores rendered body (text and html parts) into params[:body] hash.
  #
  def render_body
    if Aerogel.config.aerogel.reloader?
      TemplateNameCache.clear
      template_cache.clear
    end
    params[:body] ||= {}
    return unless params[:body].blank? # body set in the mailer definition block
    if params[:layout] == false
      layout_text = false
      layout_html = false
    else
      layout_name = params[:layout] || DEFAULT_LAYOUT
      layout_text = TemplateNameCache.fetch( "layouts/#{layout_name}.text" )
      layout_html = TemplateNameCache.fetch( "layouts/#{layout_name}.html" )
    end
    body_text = TemplateNameCache.fetch( "mailers/#{name}.text" )
    body_html = TemplateNameCache.fetch( "mailers/#{name}.html" )
    if !body_text && !body_html
      raise Aerogel::Mailer::Error.new "No body templates found for mailer '#{name}'"
    end
    if body_text
      params[:body][:text] = erb body_text, layout: layout_text, locals: params[:locals]
    end
    if body_html
      params[:body][:html] = erb body_html, layout: layout_html, locals: params[:locals]
    end
    true
  end

end # class Definition
end # module Aerogel::Mailer

