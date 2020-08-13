# directory from which irb was started
start_dir = Dir.pwd

# Directory for irb config files
base_conf_dir = File.join(ENV['HOME'], ".rb.d")
irb_conf_dir  = File.join(base_conf_dir, "irb")

# load debundle - allow loading of unbundled gems while running under bundler
#load File.join(base_conf_dir, "debundle.rb")

## General irb / rails console customization
# Get a list of irb init files, ignorning those starting with '_'
#Dir.chdir(irb_conf_dir)
#startup_files = Dir.glob("[^_]*.rb")

#startup_files.each do |f|
#  begin
#    load f
#  rescue Exception => e
#    puts e.backtrace
#    puts e.message
#    puts "Error loading #{f}"
#  end
#end

## Project-specific settings
# For every directory ~/.rb.d/projects/XYZ, if XYZ in in the pwd when irb is started,
# load all the files therein.
#projects_dir = File.join(base_conf_dir, "projects")
#Dir.chdir(projects_dir)
#projects = Dir.glob("[^.]*")
#
#projects.each do |project|
#  if start_dir.include?(project)
#    Dir.chdir(File.join(projects_dir, project))
#    Dir.glob("[^_]*.rb") do |project_file|
#      load project_file
#    end
#  end
#end
