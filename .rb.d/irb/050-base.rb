
def rails?
  ($0 == 'irb' && ENV['RAILS_ENV']) || ($0 == 'script/rails' && Rails.env) || (defined?(Rails) && Rails.env)
end
