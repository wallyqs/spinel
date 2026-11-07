# spinel: gc-stress
# `(x or y).dup` whose `or` hands on a String handle (an ARGV element), in
# a program that can give a builtin value instance variables: the copy that
# carries them over held the receiver in a const char * and was handed the
# sp_String * handle, and the C compile failed (incompatible pointer types
# initializing 'const char *' with an expression of type 'sp_String *').
[1].instance_variable_set(:@tag, 1)
PNG = ARGV[0] == "--png" ? (ARGV[1] or abort "--png needs a prefix").dup : nil
p PNG
a = (ARGV[1] || "none").dup
b = (ARGV[0] && ARGV[1]).clone
c = (ARGV[7] or "fallback").dup
junk = (1..50_000).map { |i| "s#{i}" * 2 }
GC.start
a << "!"
p a, b, c, PNG, junk.size, ARGV[1]
