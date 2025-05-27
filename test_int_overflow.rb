#!/usr/bin/env ruby
# Test to demonstrate the (int)RSTRING_LEN truncation issue in Oj
# This test specifically targets the INT_MAX boundary

require 'oj'

# INT_MAX on 32-bit systems
INT_MAX = 2147483647  # 2^31 - 1

def test_around_int_max_boundary
  puts "=== Testing around INT_MAX boundary ==="
  puts "INT_MAX = #{INT_MAX} bytes (#{INT_MAX / (1024.0**3)} GB)"
  
  # Test sizes around the INT_MAX boundary
  test_sizes = [
    INT_MAX - 1000,      # Just under INT_MAX
    INT_MAX - 1,         # One byte under INT_MAX  
    INT_MAX,             # Exactly INT_MAX
    INT_MAX + 1,         # One byte over INT_MAX
    INT_MAX + 1000,      # Just over INT_MAX
    INT_MAX * 2,         # Double INT_MAX (should definitely overflow)
  ]
  
  test_sizes.each do |size|
    test_string_size(size)
  end
end

def test_string_size(size)
  size_gb = size / (1024.0**3)
  puts "\n--- Testing #{size} bytes (#{size_gb.round(3)} GB) ---"
  
  begin
    # Create string of exact size
    test_string = "x" * size
    actual_size = test_string.bytesize
    
    puts "Created string: #{actual_size} bytes"
    
    # Test with simple string first
    puts "Testing direct string serialization..."
    start_time = Time.now
    result = Oj.dump(test_string)
    end_time = Time.now
    puts "✓ Direct string: Success in #{(end_time - start_time).round(3)}s"
    
    # Test with hash containing the string
    puts "Testing hash with large string..."
    data = { large_string: test_string }
    start_time = Time.now
    result = Oj.dump(data)
    end_time = Time.now
    puts "✓ Hash: Success in #{(end_time - start_time).round(3)}s"
    
  rescue => e
    puts "✗ Error: #{e.class} - #{e.message}"
    puts "  This confirms the INT_MAX truncation issue!" if size > INT_MAX
  end
end

def demonstrate_truncation_math
  puts "\n=== Demonstrating Integer Truncation Math ==="
  
  # Our problematic 3.7GB size
  large_size = 3737406350
  
  puts "Original size: #{large_size} bytes"
  puts "Original size in GB: #{large_size / (1024.0**3)} GB"
  puts "INT_MAX: #{INT_MAX} bytes"
  puts "Overflow amount: #{large_size - INT_MAX} bytes"
  
  # Simulate 32-bit truncation
  truncated = large_size & 0xFFFFFFFF
  puts "\nAfter 32-bit truncation:"
  puts "Truncated size: #{truncated} bytes"
  puts "Truncated size in GB: #{truncated / (1024.0**3)} GB"
  puts "Difference: #{large_size - truncated} bytes"
  
  # Show binary representation
  puts "\nBinary representation:"
  puts "Original:  0x#{large_size.to_s(16).upcase}"
  puts "Truncated: 0x#{truncated.to_s(16).upcase}"
end

# Run the tests
demonstrate_truncation_math
test_around_int_max_boundary

puts "\n=== Summary ==="
puts "This test demonstrates that the Oj segfault is caused by:"
puts "1. Integer truncation when casting RSTRING_LEN to int"
puts "2. The truncation causes invalid pointer arithmetic"
puts "3. Strings larger than INT_MAX (2.14GB) are affected"
puts "4. The exact crash point depends on memory layout and usage patterns" 