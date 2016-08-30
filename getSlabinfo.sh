#!/bin/bash

DEBUG=true
#OUTPUT=`ssh n$shard "echo \"select o.shard_id from organizations o, shard_info si WHERE coalesce(o.shard_id,1) = si.shard_id limit 1;\" | psql -U www-data meraki_shard_production" | grep -v -e "shard" -e "-" -e "row" | grep '[0-9]' | tr -d ' '`
while true; do
  while read line; do
  #  echo $line
    ip_model=($line)
    ip=${ip_model[0]}
    model=${ip_model[1]}
    timestamp=`date +%s`
  # the -n makes the ssh not accept stdin which is required or else the ssh command will eat the rest of the input file
    command="ssh -n -o StrictHostKeyChecking=no root@$ip cat /proc/slabinfo"
    filename="slabinfo/$timestamp.log"
    echo $command > $filename
    SLABINFO_MONITOR=`$command`
    echo "$SLABINFO_MONITOR" >> $filename
    SLABINFO_MONITOR=""
  done < "config/MHSWIRELESS_THEONE.txt"
  sleep 300
done
