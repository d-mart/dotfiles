# only do anything if in Rails
if rails?

  def sql(query)
    ActiveRecord::Base.connection.select_all(query)
  end

  def change_log(stream)
    if defined? ActiveRecord::Base
      ActiveRecord::Base.logger = Logger.new stream
      ActiveRecord::Base.clear_active_connections!
    end
  end

  def show_log
    change_log STDOUT
  end

  def hide_log
    change_log nil
  end

  change_log STDOUT

end
