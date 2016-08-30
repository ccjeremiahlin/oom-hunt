#!/usr/bin/env ruby

require 'thread'
require 'set'

ALLOC_PATTERN = /.*kmalloc-8192 alloc (?<addr>0x\h{8}).*/
FREE_PATTERN = /.*kmalloc-8192 free (?<addr>0x\h{8}).*/
CALLSTACK_PATTERN = /.*\[<\h{8}>\] \(.+\).*/
AGEFILTER = 300 #5 minutes in seconds
RESULT_FOLDER = "result"

$pattern = ""
$pattern_map = {}
$printed_set = Set.new
$curraddr = nil

def addToHash(addr, pattern)
  return if addr.nil?
  pattern+="============================================================\n"
  timestamp = Time.now.to_i
  $pattern_map[addr] = [pattern, timestamp]
end

th = Thread.new do
  loop do
    now = Time.now.to_i
    filename = "#{RESULT_FOLDER}/#{now}.log"
    File.open(filename, "w") do |f|
      $pattern_map.each do |key, value|
        age = (now - value[1])
        if age > AGEFILTER
          puts "Age: #{age}"
          f.puts "Age: #{age}"
          puts value[0]
          f.puts value[0]
        end
      end
    end
    sleep AGEFILTER
  end
end

ARGF.each do |line|
  match_alloc = ALLOC_PATTERN.match(line)
  if match_alloc
    addToHash($curraddr, $pattern)
    $pattern = line
    $curraddr = match_alloc[:addr]
    next
  end
  match_free = FREE_PATTERN.match(line)
  if match_free
    addToHash($curraddr, $pattern)
    $pattern_map.delete match_free[:addr]
    $pattern = ""
    $curraddr = nil
    next
  end
  match_call = CALLSTACK_PATTERN.match(line)
  $pattern += line if match_call && $curraddr
end

puts "Reading <EOF>"
th.join
