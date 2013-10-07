## UI enhancement libraries
require 'irb/completion'
require 'irb/ext/save-history' unless IRB.version.include? "DietRB"

# Non-printable chars in prompt confuse IRB -
# it seems to do a strlen and won't erase all characters
# on the line when doing readline-y things.
_n = "\e[0m"
_w = "\e[1;37m"
_c = rails? ? "\e[1;31m" : "\e[1;34m"

_n = ""
_w = ""
_c = ""

IRB.conf[:AUTO_INDENT] = true
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:PROMPT][:CUSTOM] = {
  :PROMPT_I => "#{_c}%02n#{_w} >> #{_n}",
  :PROMPT_N => "#{_c}%02n#{_w} >> #{_n}",
  :PROMPT_C => "#{_c}%02n#{_w} ?> #{_n}",
  :PROMPT_S => nil,
  :RETURN => "=> %s\n"
}
IRB.conf[:PROMPT_MODE] = :CUSTOM
