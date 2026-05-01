require 'resolv'

puts Resolv.getaddress("127.0.0.1")
puts Resolv.getaddress("127.0.0.1") == "127.0.0.1"
addr = Resolv.getaddress("127.0.0.1")
puts addr.length
