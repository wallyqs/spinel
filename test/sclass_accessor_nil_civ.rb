# A `class << self` accessor over a class-level ivar the class body stores
# only nil into: the accessor reads and writes civ_<Class>_<x>, which was
# never declared, so the C compile failed (use of undeclared identifier
# 'civ_Surface_active'). A non-nil store, or a `def self.` that names the
# ivar, declared it.
class Surface
  @active = nil
  class << self; attr_accessor :active; end
  def initialize(name)
    raise "one live surface" if Surface.active
    @name = name
    Surface.active = self
  end
  attr_reader :name
  def close = (Surface.active = nil if Surface.active.equal?(self))
end

p Surface.active
s = Surface.new("main")
p Surface.active.name, Surface.active.equal?(s)
begin
  Surface.new("second")
rescue => e
  p e.message
end
s.close
p Surface.active
p Surface.new("third").name

class Log
  @level = nil
  class << self
    attr_reader :level
    attr_writer :level
    attr_writer :sink
  end
  @sink = nil
  def self.sink = @sink
end
p Log.level
Log.level = 2
p Log.level
Log.level = "debug"
p Log.level
Log.sink = [1, 2]
p Log.sink

class Other
  @active = nil
  class << self; attr_accessor :active; end
end
Other.active = :other
p Other.active, Surface.active.name
