# spinel: int64 -- the values are Bignums past 2**63
# A 64-bit unsigned result at or past 2**63 is the unsigned Integer, as
# CRuby's Fiddle gives it: it came back as the negative signed value with
# the same bits. And such a value passed as a 64-bit unsigned argument is
# those bits: it raised RangeError (bignum too big to convert into 'long').
require "fiddle"

libc = Fiddle.dlopen(nil)
big = 18000000000000000000 # 2**64 - 446744073709551616
[Fiddle::TYPE_UINTPTR_T, Fiddle::TYPE_UINT64_T, Fiddle::TYPE_SIZE_T, Fiddle::TYPE_UINT32_T].each do |t|
  strtoull = Fiddle::Function.new(libc["strtoull"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], t)
  p strtoull.call(big.to_s, nil, 10)
end
p Fiddle::Function.new(libc["strtoull"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT],
                       Fiddle::TYPE_UINT64_T).call("1", nil, 10)

# llabs shows the bits that went in: 2**64 - 5 is the bits of -5.
[Fiddle::TYPE_UINTPTR_T, Fiddle::TYPE_UINT64_T].each do |t|
  llabs = Fiddle::Function.new(libc["llabs"], [t], Fiddle::TYPE_LONG_LONG)
  p [llabs.call(-5), llabs.call(2**64 - 5), llabs.call(2**63)]
  begin
    llabs.call(2**64)
  rescue RangeError
    puts "2**64: RangeError"
  end
end

# The same across a closure: C hands Ruby the argument and Ruby hands C the
# result, both 64-bit unsigned.
seen = nil
cb = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_UINT64_T, [Fiddle::TYPE_UINT64_T]) do |v|
  seen = v
  v + 1
end
id = Fiddle::Function.new(cb, [Fiddle::TYPE_UINT64_T], Fiddle::TYPE_UINT64_T)
p id.call(big)
p seen
