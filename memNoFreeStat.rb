#!/usr/bin/env ruby

ALLOC_CALL_PATTERNS = [/.*__kmalloc.*/, /.*osl_malloc.*/]
ID_PATTERN = /.+\[<\h{8}>\] (?<id>\(.+\)).*/

$pattern_ids_count = Hash.new(0)
$curr_id = nil
$looking_for_id = false

ARGF.each do |line|
  alloc_call = ALLOC_CALL_PATTERNS.select { |reg| reg.match(line) }
  if !alloc_call.empty?
    $looking_for_id = true
    next
  end
  if $looking_for_id
    id_match = ID_PATTERN.match(line)
    if id_match
      $curr_id = id_match[:id]
      $looking_for_id = false
      $pattern_ids_count[$curr_id] += 1
    end
  end
end

puts "Pattern ID \t-\t-\t Count"

$pattern_ids_count.each do |key, value|
  puts "#{key} \t-\t-\t #{value}"
end
