# spinel: gc-stress
# A conditional whose String arm is an `||` / `&&` handing on a handle
# (an ARGV element) beside a nil arm: the arm went into the C conditional
# as the sp_String * handle beside the nil arm's const char *, and the
# result was read as bytes, an alias of the handle struct the collector did
# not keep the String alive by. After a collection it read freed memory.
PREFIX = ARGV[0] == "--out" ? (ARGV[1] or abort "--out needs a prefix") : nil
SUFFIX = ARGV.size > 1 ? (ARGV[2] || "none") : nil
BOTH = ARGV[0] ? (ARGV[1] && ARGV[1]) : nil
UNLESS = (ARGV[1] or "x") unless ARGV.empty?

def show(label) = "#{PREFIX}-#{label}"

junk = (1..100_000).map { |i| "s#{i}" * 3 }
GC.start
shot = lambda { |name| puts show(name) }
shot.("initial")
p PREFIX, SUFFIX, BOTH, UNLESS
p junk.size
p ARGV.empty? ? (ARGV[5] or "fallback") : nil
