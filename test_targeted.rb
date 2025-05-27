#!/usr/bin/env ruby

require 'oj'

def test_oj_modes_with_large_string(size_mb)
  puts "\n=== Testing #{size_mb}MB string with different Oj modes ==="
  
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
  
  # Test different Oj modes
  modes = [
    { name: "default", options: {} },
    { name: "compat", options: { mode: :compat } },
    { name: "strict", options: { mode: :strict } },
    { name: "object", options: { mode: :object } },
    { name: "null", options: { mode: :null } },
    { name: "custom", options: { mode: :custom } },
    { name: "rails", options: { mode: :rails } },
    { name: "wab", options: { mode: :wab } }
  ]
  
  modes.each do |mode_info|
    puts "\n--- Testing #{mode_info[:name]} mode ---"
    
    start_time = Time.now
    begin
      result = Oj.dump(data, mode_info[:options])
      end_time = Time.now
      puts "✓ Success! Serialized in #{(end_time - start_time).round(2)} seconds"
      puts "  Result size: #{result.bytesize / (1024.0 * 1024)} MB"
    rescue => e
      end_time = Time.now
      puts "✗ Error after #{(end_time - start_time).round(2)} seconds:"
      puts "  #{e.class}: #{e.message}"
      puts "  Backtrace:"
      puts e.backtrace.first(3).map { |line| "    #{line}" }
    end
  end
end

def test_just_large_string(size_mb)
  puts "\n=== Testing #{size_mb}MB string directly (no hash) ==="
  
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
  
  start_time = Time.now
  begin
    result = Oj.dump(large_html)
    end_time = Time.now
    puts "✓ Success! Serialized in #{(end_time - start_time).round(2)} seconds"
    puts "  Result size: #{result.bytesize / (1024.0 * 1024)} MB"
    return true
  rescue => e
    end_time = Time.now
    puts "✗ Error after #{(end_time - start_time).round(2)} seconds:"
    puts "  #{e.class}: #{e.message}"
    puts "  Backtrace:"
    puts e.backtrace.first(3).map { |line| "    #{line}" }
    return false
  end
end

# Test with a size that we know works (2GB)
puts "Testing with 2GB first..."
test_oj_modes_with_large_string(2000)

# Test just the string without the hash structure
puts "\n" + "="*60
test_just_large_string(3700)

# Test with the problematic size (3.7GB)
puts "\n" + "="*60
test_oj_modes_with_large_string(3700) 