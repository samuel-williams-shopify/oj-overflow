#!/usr/bin/env ruby

require 'oj'

# Create a large HTML string similar to what was shown in GDB
# Starting with the pattern from the GDB output
html_start = '<div id="shopify-section-template--17422730821674__eyJzZWN0aW9uIjoibWFpbi1jYXJ0LWN1c3RvbSIsInNpZ25hdHVyZSI6IuOCq+ODvOODiOODoeODi+ODpeODvCJ9" class="shopify-section" data-shopify-editor-section="{&quot'

# Create a pattern that will be repeated to reach ~3.7GB
# Let's create a chunk that's about 1MB and repeat it
chunk_size = 1024 * 1024  # 1MB
chunk = ";" * chunk_size

# Calculate how many chunks we need for ~3.7GB
target_size = 3.7 * 1024 * 1024 * 1024  # 3.7GB in bytes
num_chunks = (target_size / chunk_size).to_i

puts "Creating large HTML string..."
puts "Target size: #{target_size / (1024.0 * 1024 * 1024)} GB"
puts "Chunk size: #{chunk_size / (1024.0 * 1024)} MB"
puts "Number of chunks: #{num_chunks}"

# Build the large string
large_html = html_start.dup
num_chunks.times do |i|
  large_html << chunk
  if i % 100 == 0
    current_size = large_html.bytesize / (1024.0 * 1024 * 1024)
    puts "Progress: #{i}/#{num_chunks} chunks, current size: #{current_size.round(2)} GB"
  end
end
large_html << "</div>"

puts "Large HTML string created. Size: #{large_html.bytesize / (1024.0 * 1024 * 1024)} GB"

# Create the data structure similar to what was shown in GDB
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

puts "Data structure created. Attempting to serialize with Oj..."

begin
  # Try to serialize with Oj
  result = Oj.dump(data)
  puts "Success! Serialized data size: #{result.bytesize / (1024.0 * 1024 * 1024)} GB"
rescue => e
  puts "Error occurred during serialization:"
  puts "#{e.class}: #{e.message}"
  puts e.backtrace.first(10)
end
