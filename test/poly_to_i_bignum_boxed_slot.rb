# spinel: int64 -- the values are Bignums
# `value.to_i` on a boxed value, when a class of the program owns `to_i`,
# goes through a dispatch whose fallthrough serves the builtin receivers.
# With the result boxed it still took the sp_int conversion and boxed that,
# so a Bignum receiver raised RangeError (bignum too big to convert into
# 'long') where CRuby answers the Bignum itself.
class Meters
  def initialize(n) = (@n = n)
  def to_i = @n
end

def out(value, type)
  case type
  when :int then value.to_i
  when :float then value.to_f
  else value
  end
end

p out(2**70, :int)
p out(2**64 - 1, :int)
p out(-(2**65), :int)
p out(Meters.new(3), :int)
p out(Meters.new(2**66), :int)
p out(7, :int), out("12", :int), out(3.9, :int)
h = {big: out(18000000000000000000, :int)}
p h
p out(2**70, :float)
