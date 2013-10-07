# Print current Ruby version, detecting RVM/rbenv
def rvm?
  system "which rvm > /dev/null 2> /dev/null"
end

def rbenv?
  system "which rbenv > /dev/null 2> /dev/null"
end

def print_ruby_version
  real_version = "#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"

  manager, version = if rvm?
                       ["RVM", `rvm current`.split("\n").last]
                     elsif rbenv?
                       ["rbenv", `rbenv version`.strip]
                     else
                       [nil, real_version]
                     end

  if version =~ /system/
    system_raw_version = `$(whereis ruby) --version`
    system_major = system_raw_version.match(/ruby (\d\.\d\.\d)/).captures.first
    system_patch = system_raw_version.match(/patchlevel (\d+)/).captures.first
    version = version.sub(/system/, "system (#{system_major}-p#{system_patch})")
  end

  if version.match(/\d\.\d\.\d-p\d+/).to_s != real_version
    manager = "(#{manager || 'built-in ruby'} bypassed)"
    version = real_version
  end

  puts "\e[1;4;36m" << [manager, "using", version].join(" ") << "\e[0m"
end

print_ruby_version
