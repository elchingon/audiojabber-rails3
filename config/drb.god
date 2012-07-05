@root = File.dirname(File.dirname(__FILE__))

def generic_monitoring(w, options = {})
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 10.seconds
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = options[:memory_limit]
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = options[:cpu_limit]
      c.times = 5
    end
  end

  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

God.watch do |w|
  script = "#{@root}/script/custom/basic_muc_drb.rb"
  w.name = "drb-script"
  w.group = "drb"
  w.interval = 60.seconds
  w.start = "ruby #{script}"
  w.restart = "ruby #{script}"
  w.start_grace = 20.seconds
  w.restart_grace = 20.seconds
  w.keepalive

  generic_monitoring(w, :cpu_limit => 80.percent, :memory_limit => 100.megabytes)
end