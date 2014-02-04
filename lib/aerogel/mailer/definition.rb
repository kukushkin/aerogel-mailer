module Aerogel::Mailer
class Definition

  include Aerogel::Render::Scope

  attr_accessor :name, :blk, :params

  def initialize( name, blk )
    self.name = name.to_sym
    self.params = {}
    self.blk = blk

    Aerogel::Mailer::Definition.register_mailer( self )
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

  def body( str )
    params[:body] = str
  end

  def compile( *args )
    unless args.size == blk.arity
      raise ArgumentError.new("wrong number of arguments for mailer '#{name}': #{args.size} for #{blk.arity}")
    end
    @self_before_instance_eval = eval "self", blk.binding
    # @self_before_instance_eval = scope
    instance_exec( *args, &blk )
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


end # class Definition
end # module Aerogel::Mailer

