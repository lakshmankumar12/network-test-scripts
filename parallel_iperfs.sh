#!/bin/bash

start_port=7020
server=1
count=5
fileprefix=parallel_iperf
rate=2M
parallel=1
prot="tcp"
listfile=""

function usage() {
  echo "$0 (--server|--client) [--count <n,def:5>] [--rate <rate:as-is-to-iperf-client,eg:10M>] [--parallel <n:as-is-Parg,eg:3] [--udp|--tcp(default)] [--listfile <file>]"
  echo "   --listfile should have values in this fashion per-line:"
  echo "            role=server|client port=<port> rate=<rate> prot=tcp|udp parallel=1"
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
      ;;
    --udp)
      prot="udp"
      ;;
    --listfile)
      listfile=$1
      shift 1
      ;;
  --count)
      count=$1
      shift 1
      ;;
    *)
      echo "Not recognized option:$key"
      usage
      ;;
  esac
done

if [ -n "$listfile" ] ; then
  if [ ! -f "$listfile" ] ; then
    echo "Couldn't locate $listfile"
    exit 1
  fi
  i=0
  while read line ; do
    i=$((i+1))
    port=0
    rate=0
    prot="tcp"
    role="client"
    parallel=1
    protarg=""
    eval $line
    if [ $port == 0 ] ; then
      echo "port:$port is 0 in line:$line"
      exit 1
    fi
    if [ "$role" != "server" -a $rate == 0 ] ; then
      echo "rate:$rate is 0 in line:$line"
      exit 1
    fi
    if [ "$prot" = "udp" ] ; then
      protarg="-u"
    fi
    if [[ "$role" = "server" ]] ; then
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
    done < <(grep -v '^[[:space:]]*#' $listfile)
else
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
fi

echo "Started and waiting"
wait



