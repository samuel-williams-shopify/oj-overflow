#!/usr/bin/env ruby

require 'oj'

def test_oj_with_size(size_mb)
  puts "\n=== Testing with #{size_mb}MB string ==="
  
  # Create a string of the specified size
  html_start = '<div id="shopify-section-template--17422730821674__eyJzZWN0aW9uIjoibWFpbi1jYXJ0LWN1c3RvbSIsInNpZ25hdHVyZSI6IuOCq+ODvOODiOODoeODi+ODpeODvCJ9" class="shopify-section" data-shopify-editor-section="{&quot'
  
  target_size = size_mb * 1024 * 1024  # Convert MB to bytes
  remaining_size = target_size - html_start.bytesize - 6  # Account for closing </div>
  
  if remaining_size > 0
    # Fill with repeated content
    filler = "x" * [remaining_size, 1024].min
    repetitions = remaining_size / filler.length
    remainder = remaining_size % filler.length
    
    large_html = html_start + (filler * repetitions) + ("x" * remainder) + "</div>"
  else
    large_html = html_start + "</div>"
  end
  
  puts "Created string of size: #{large_html.bytesize / (1024.0 * 1024)} MB"
  
  # Create the data structure
  data = {
    html: large_html,
    json: {
      id: "template--17422730821674__eyJzZWN0aW9uIjoibWFpbi1jYXJ0LWN1c3RvbSIsInNpZ25hdHVyZSI6IuOCq+ODvOODiOODoeODi+ODpeODvCJ9",
      type: "main-cart-custom",
      disabled: false,
      blocks: [],
      contentForIndexSection: false,
      accessedThemeSettings: ["cart_type", "show_vendor"]
    }
  }
  
  puts "Attempting to serialize with Oj..."
  
  start_time = Time.now
  begin
    result = Oj.dump(data)
    end_time = Time.now
    puts "✓ Success! Serialized in #{(end_time - start_time).round(2)} seconds"
    puts "  Result size: #{result.bytesize / (1024.0 * 1024)} MB"
    return true
  rescue => e
    end_time = Time.now
    puts "✗ Error after #{(end_time - start_time).round(2)} seconds:"
    puts "  #{e.class}: #{e.message}"
    puts "  Backtrace:"
    puts e.backtrace.first(5).map { |line| "    #{line}" }
    return false
  end
end

# Test with progressively larger sizes
sizes_to_test = [1, 10, 50, 100, 500, 1000, 2000, 3700]  # MB

sizes_to_test.each do |size|
  success = test_oj_with_size(size)
  unless success
    puts "\nFailed at #{size}MB - stopping here"
    break
  end
  
  # Add a small delay to let the system recover
  sleep(1) if size > 100
end

puts "\nTest completed!" 