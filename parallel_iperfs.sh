#!/bin/bash

start_port=7020
server=1
count=5
fileprefix=parallel_iperf
rate=2M
parallel=1
prot="tcp"

function usage() {
  echo "$0 (--server|--client) [--rate <rate:as-is-to-iperf-client,eg:10M>] [--parallel <n:as-is-Parg,eg:3] [--udp|--tcp(default)]"
  exit 1
}

while [[ $# > 0  ]] ; do
  key="$1"
  shift 1
  case $key in
    --server)
      server=1
      ;;
    --client)
      server=0
      ;;
    -h|--help)
      usage
      ;;
    --rate)
      rate=$1
      shift 1
      ;;
    --parallel)
      parallel=$1
      shift 1
      ;;
    --tcp)
      prot="tcp"
      shift 1
      ;;
    --udp)
      prot="udp"
      shift 1
      ;;
    *)
      echo "Not recognized option:$key"
      usage
      ;;
  esac
done


protarg=""
if [ $prot = "udp" ] ; then
  protarg="-u"
fi
for i in $(seq 1 $count) ; do
  port=$((${start_port} + ${i}))
  if [[ $server = 1 ]] ; then
    cmd="./iperf3 -s -B ${mip} -p ${port} --logfile ${fileprefix}_${i}_server &"
  else
    cmd="./iperf3 -B ${mip} -p ${port} -c ${pip} -i 1 -t 3600 -b${rate} -P${parallel} --logfile ${fileprefix}_${i}_client ${protarg} &"
  fi
  echo "doing ${cmd}"
  eval $cmd
  if [ $? -ne 0 ] ; then
    echo "Not successful.."
    exit 1
  fi
done

echo "Started and waiting"
wait



