#!/usr/bin/env ruby
# Minimal reproduction of Oj segfault with large strings
# 
# This script creates a ~3.7GB string and attempts to serialize it with Oj,
# which should result in a segmentation fault.

require 'oj'

puts "Creating 3.7GB string..."

# Create a large string similar to the original issue
html_start = '<div id="shopify-section-template--17422730821674__eyJzZWN0aW9uIjoibWFpbi1jYXJ0LWN1c3RvbSIsInNpZ25hdHVyZSI6IuOCq+ODvOODiOODoeODi+ODpeODvCJ9" class="shopify-section">'

# Create 3.7GB of content
target_size = 3.7 * 1024 * 1024 * 1024  # 3.7GB
chunk = "x" * (1024 * 1024)  # 1MB chunks
num_chunks = (target_size / chunk.bytesize).to_i

large_html = html_start.dup
num_chunks.times { large_html << chunk }
large_html << "</div>"

puts "String created: #{large_html.bytesize / (1024.0**3)} GB"

# Create the problematic data structure
data = {
  html: large_html,
  json: {
    id: "template--17422730821674__test",
    type: "main-cart-custom",
    disabled: false,
    blocks: [],
    contentForIndexSection: false,
    accessedThemeSettings: ["cart_type", "show_vendor"]
  }
}

puts "Attempting Oj.dump() - this should segfault..."

begin
  result = Oj.dump(data)
  puts "Unexpected success! Result size: #{result.bytesize / (1024.0**3)} GB"
rescue => e
  puts "Error: #{e.class} - #{e.message}"
end 