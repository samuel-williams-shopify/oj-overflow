#!/usr/bin/env ruby
# Comparison between Oj and standard JSON library with large strings

require 'oj'
require 'json'

def test_serializers_with_size(size_mb)
  puts "\n=== Testing #{size_mb}MB string ==="
  
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
  
  puts "Data created: #{html_content.bytesize / (1024.0 * 1024)} MB"
  
  # Test standard JSON
  puts "\n--- Testing standard JSON library ---"
  start_time = Time.now
  begin
    result = JSON.generate(data)
    end_time = Time.now
    puts "✓ JSON Success! Time: #{(end_time - start_time).round(2)}s, Size: #{result.bytesize / (1024.0 * 1024)} MB"
  rescue => e
    end_time = Time.now
    puts "✗ JSON Error after #{(end_time - start_time).round(2)}s: #{e.class} - #{e.message}"
  end
  
  # Test Oj
  puts "\n--- Testing Oj library ---"
  start_time = Time.now
  begin
    result = Oj.dump(data)
    end_time = Time.now
    puts "✓ Oj Success! Time: #{(end_time - start_time).round(2)}s, Size: #{result.bytesize / (1024.0 * 1024)} MB"
  rescue => e
    end_time = Time.now
    puts "✗ Oj Error after #{(end_time - start_time).round(2)}s: #{e.class} - #{e.message}"
  end
end

# Test with progressively larger sizes
sizes = [10, 50, 100, 500, 1000, 2000]

sizes.each do |size|
  test_serializers_with_size(size)
  
  # Add a pause for larger sizes to let system recover
  sleep(1) if size >= 500
end

puts "\n=== Summary ==="
puts "This comparison shows how both libraries handle large strings."
puts "The segfault typically occurs with Oj at around 3.7GB."
puts "Standard JSON library may handle larger sizes more gracefully." 