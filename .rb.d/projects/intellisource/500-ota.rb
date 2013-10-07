if rails?

  def monitor_redis
    # Le awsum redis monitoring irb tidbit (notice ANSI escape code)
    while true
      puts "\e[0;0H \e[2J" # cursor to 0,0 ; clear screen
      puts Time.zone.now
      ap REDIS.zrange("firmware_updater:service_points", 0, -1)
      puts "^^^^^ Serial ^^^^     vvvv Group vvvvv"
      ap REDIS.lrange('firmware_extensions:group_updater', 0, -1)
      sleep 2
    end
  end

  def clear_redis
    REDIS.del("firmware_extensions:group_updater")
    REDIS.del("firmware_updater:service_points")
  end

  def monitor_pubsub_ota
    hide_log
    while true
      sleep 2
      msgs = F1Message.last(20).select { |m| m.serial_number == 4173802 }
      next if msgs.empty?
      msg = msgs.last
      puts "\e[0;0H \e[2J" # cursor to 0,0 ; clear screen
      puts Time.zone.now
      puts "##{msg.id}: #{msg}"
      ack = MessageAcknowledged.where(:reference_id => msg.id)
      ack.present? ? puts("~~ Matched ~~") : puts("XX unmatched XX")
    end
  end

end
