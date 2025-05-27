#!/usr/bin/env ruby
# Test to demonstrate the negative int → huge size_t conversion
# This shows the exact mechanism causing the Oj segfault

def demonstrate_negative_int_conversion
  puts "=== Demonstrating Negative Int → Huge size_t Conversion ==="
  puts
  
  # Simulate the problematic code pattern
  original_size = 2**31  # INT_MAX + 1 = 2,147,483,648
  
  puts "Original size_t value: #{original_size}"
  puts "This is INT_MAX + 1: #{original_size == 2147483647 + 1}"
  puts
  
  # Simulate what happens in C:
  # size_t len = (int)RSTRING_LEN(str);
  
  # In Ruby, we can simulate this with pack/unpack
  # Pack as signed 32-bit int, then unpack as unsigned 64-bit
  packed_as_int = [original_size].pack('l')  # signed long (32-bit)
  negative_int = packed_as_int.unpack('l')[0]
  
  puts "After cast to signed int: #{negative_int}"
  puts "This is negative: #{negative_int < 0}"
  puts
  
  # Now simulate assignment back to size_t (unsigned)
  # In C: size_t len = (size_t)negative_int
  packed_negative = [negative_int].pack('q')  # signed 64-bit
  huge_size_t = packed_negative.unpack('Q')[0]  # unsigned 64-bit
  
  puts "After assignment to size_t: #{huge_size_t}"
  puts "This is approximately: #{huge_size_t / (1024.0**6)} exabytes"
  puts
  
  puts "=== The Problem ==="
  puts "Oj thinks it needs to read #{huge_size_t} bytes"
  puts "But the actual string is only #{original_size} bytes"
  puts "Result: Immediate segfault trying to access ~18 exabytes"
end

def show_boundary_behavior
  puts "\n=== Boundary Behavior ==="
  puts
  
  test_values = [
    2147483646,  # INT_MAX - 1
    2147483647,  # INT_MAX (exactly)
    2147483648,  # INT_MAX + 1 (problematic)
    2147483649,  # INT_MAX + 2
  ]
  
  test_values.each do |value|
    # Simulate the cast
    packed = [value].pack('l')
    int_result = packed.unpack('l')[0]
    
    if int_result >= 0
      puts "#{value}: Cast to int = #{int_result} (✅ positive, safe)"
    else
      # Show what happens when assigned back to size_t
      huge_result = [int_result].pack('q').unpack('Q')[0]
      puts "#{value}: Cast to int = #{int_result} → size_t = #{huge_result} (❌ HUGE!)"
    end
  end
end

def create_c_reproduction
  puts "\n=== C Code Reproduction ==="
  puts
  puts "Here's the C code that demonstrates this issue:"
  puts
  puts <<~C_CODE
    #include <stdio.h>
    #include <limits.h>
    #include <stddef.h>
    
    int main() {
        size_t original_size = (size_t)INT_MAX + 1;  // 2,147,483,648
        size_t len = (int)original_size;             // The problematic pattern
        
        printf("Original size: %zu\\n", original_size);
        printf("After cast: %zu\\n", len);
        printf("Ratio: %.1fx larger\\n", (double)len / original_size);
        
        return 0;
    }
  C_CODE
  
  puts "Expected output:"
  puts "Original size: 2147483648"
  puts "After cast: 18446744071562067968"
  puts "Ratio: 8589934592.0x larger"
end

# Run all demonstrations
demonstrate_negative_int_conversion
show_boundary_behavior
create_c_reproduction

puts "\n=== Summary ==="
puts "The Oj segfault is caused by:"
puts "1. Casting size_t to int when size > INT_MAX"
puts "2. This creates a negative int value"
puts "3. Assigning negative int back to size_t creates huge positive value"
puts "4. Oj tries to read ~18 exabytes → immediate segfault" 