#!/usr/bin/env ruby

LOGPATH = "slabmonitor"
FILENAME_PREFIX = "messages"
CONFIG = "config"

threads = []

def work(ip)
  cmd_turnon_slab_trace = "ssh -n -o StrictHostKeyChecking=no -t root@#{ip} \"echo 1 > /sys/kernel/slab/kmalloc-8192/trace\""
  "Turning on slab trace ..."
  %x(#{cmd_turnon_slab_trace})
  "Start reading parsing results ..."
  command_to_run = "ssh -n root@#{ip} tail -F /var/log/messages | ruby parse_kmalloc_trace_result.rb"
  IO.popen(command_to_run) do |io|
    io.each_line do |line|
      puts line
    end
  end
end

File.open("#{CONFIG}/MHSWIRELESS_THEONE.txt", "r") do |f|
    f.each_line do |line|
      fields = line.split(' ')
      ip, model = fields[0], fields[1]
      threads << Thread.new(ip)  do |ip|
        work(ip)
      end
    end
end

threads.each do |th|
  th.join
end
