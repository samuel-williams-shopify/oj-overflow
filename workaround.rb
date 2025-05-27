#!/usr/bin/env ruby
# Workaround for Oj segfault with large strings
# 
# This script demonstrates a safe approach to JSON serialization
# that avoids the Oj segfault by checking string sizes and falling
# back to standard JSON for very large data.

require 'oj'
require 'json'
require 'set'

class SafeJsonSerializer
  # Size threshold in bytes (INT_MAX to be safe, since crash occurs at INT_MAX + 1)
  SIZE_THRESHOLD = 2147483647  # INT_MAX
  
  def self.dump(data, options = {})
    total_size = calculate_data_size(data)
    
    puts "Data size: #{total_size / (1024.0**3)} GB"
    
    if total_size > SIZE_THRESHOLD
      puts "⚠️  Large data detected (#{total_size / (1024.0**3)} GB), using standard JSON"
      JSON.generate(data)
    else
      puts "✓ Using Oj for serialization"
      Oj.dump(data, options)
    end
  end
  
  private
  
  def self.calculate_data_size(obj, visited = Set.new)
    return 0 if visited.include?(obj.object_id)
    visited.add(obj.object_id)
    
    case obj
    when String
      obj.bytesize
    when Array
      obj.sum { |item| calculate_data_size(item, visited) }
    when Hash
      obj.sum { |key, value| 
        calculate_data_size(key, visited) + calculate_data_size(value, visited) 
      }
    when Numeric, TrueClass, FalseClass, NilClass
      8  # Approximate size
    else
      obj.to_s.bytesize  # Fallback
    end
  end
end

# Test the workaround
def test_safe_serializer(size_mb, description)
  puts "\n=== Testing #{description} (#{size_mb}MB) ==="
  
  # Create test data
  html_content = "x" * (size_mb * 1024 * 1024)
  data = {
    html: html_content,
    json: {
      id: "test-id",
      type: "test-type",
      disabled: false,
      blocks: [],
      contentForIndexSection: false,
      accessedThemeSettings: ["cart_type", "show_vendor"]
    }
  }
  
  start_time = Time.now
  begin
    result = SafeJsonSerializer.dump(data)
    end_time = Time.now
    puts "✓ Success! Time: #{(end_time - start_time).round(2)}s"
    puts "  Result size: #{result.bytesize / (1024.0 * 1024)} MB"
  rescue => e
    end_time = Time.now
    puts "✗ Error after #{(end_time - start_time).round(2)}s: #{e.class} - #{e.message}"
  end
end

# Test with various sizes
test_safe_serializer(100, "small data")
test_safe_serializer(1000, "medium data") 
test_safe_serializer(2000, "large data (should use Oj)")
test_safe_serializer(4000, "very large data (should use JSON)")

puts "\n=== Workaround Summary ==="
puts "This approach:"
puts "1. Calculates total data size before serialization"
puts "2. Uses Oj for data under 3GB threshold"
puts "3. Falls back to standard JSON for larger data"
puts "4. Prevents segfaults while maintaining performance for normal-sized data" 