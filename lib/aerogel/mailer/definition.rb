module Aerogel::Mailer
class Definition

  attr_accessor :name, :blk, :params

  def initialize( name, blk )
    self.name = name.to_sym
    self.params = {}
    self.blk = blk

    Aerogel::Mailer.register_mailer( self )
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

  def eval( *args )
    unless args.size == blk.arity
      raise ArgumentError.new("wrong number of arguments for mailer '#{name}': #{args.size} for #{blk.arity}")
    end
    self.instance_exec( *args, &blk )
    params
  end

end # class Definition
end # module Aerogel::Mailer

