#!/usr/bin/env ruby
# One-liner reproduction of the Oj INT_MAX truncation bug
# This is the minimal case for bug reports

require 'oj'

puts "Testing the exact boundary case..."
puts "This will segfault at INT_MAX + 1 (2,147,483,648 bytes)"
puts

# The one-liner that reproduces the bug:
Oj.dump('x' * 2147483648) 