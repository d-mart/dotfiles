begin
  require 'wirble'
  Wirble.init
  Wirble.colorize
rescue
  puts "\e[33mError loading wirble"
end
