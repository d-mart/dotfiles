begin
  require 'hirb'
  Hirb.enable
rescue
  puts "\e[33mError loading hirb"
end
