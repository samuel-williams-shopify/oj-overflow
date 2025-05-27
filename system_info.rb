#!/usr/bin/env ruby

require 'oj'

puts "=== System Information ==="
puts "Ruby version: #{RUBY_VERSION}"
puts "Ruby platform: #{RUBY_PLATFORM}"
puts "Ruby engine: #{RUBY_ENGINE}"
puts "Ruby description: #{RUBY_DESCRIPTION}"

puts "\n=== Oj Information ==="
puts "Oj version: #{Oj::VERSION}"
puts "Oj default options: #{Oj.default_options}"

puts "\n=== Available Oj modes ==="
[:compat, :strict, :object, :null, :custom, :rails, :wab].each do |mode|
  begin
    Oj.dump({test: "value"}, mode: mode)
    puts "✓ #{mode} mode: available"
  rescue => e
    puts "✗ #{mode} mode: #{e.class} - #{e.message}"
  end
end

puts "\n=== Memory Information ==="
# Get memory info if available
begin
  if RUBY_PLATFORM.include?('darwin')
    memory_info = `vm_stat`
    puts memory_info
  elsif RUBY_PLATFORM.include?('linux')
    memory_info = `free -h`
    puts memory_info
  end
rescue => e
  puts "Could not get memory info: #{e.message}"
end

puts "\n=== Testing small string serialization ==="
small_data = {
  html: "<div>test</div>",
  json: {
    id: "test-id",
    type: "test-type",
    disabled: false,
    blocks: [],
    contentForIndexSection: false,
    accessedThemeSettings: ["setting1", "setting2"]
  }
}

begin
  result = Oj.dump(small_data)
  puts "✓ Small data serialization works"
  puts "  Result: #{result[0..100]}#{'...' if result.length > 100}"
rescue => e
  puts "✗ Small data serialization failed: #{e.class} - #{e.message}"
end 