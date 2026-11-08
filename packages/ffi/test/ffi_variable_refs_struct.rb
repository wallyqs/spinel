# The bundled library compiles in a program whose Struct keeps a member of
# a fixed object type (a keyword initialize handing on to super) and whose
# ivar facts span every class (an instance_variable_get): attach_variable's
# reference table, through a boxed receiver, was taken for one of the
# program's Structs and its `[]=` refused.
require "ffi"

class Span
  def initialize(n) = @n = n
  attr_reader :n
end
Timing = Struct.new(:id, :span) do
  def initialize(id:, span: Span.new(0))
    super(id, span)
  end
end
tm = Timing.new(id: 1, span: Span.new(5))
p tm.instance_variable_get(:@id), tm.span.n
