#!/bin/bash

usage() {
    echo "fire_wgets.sh [-c|--count N] [-r|--resouce url] [-b|--bind <localip>] [-j|--joblog <log>] -p|-peer <peer>"
    echo "    defaults:"
    echo "           --count     10"
    echo "           --resource  1G_file"
    echo "           --joblog    /tmp/joblog"
    echo "    peer is mandatory"
    exit 1
}

count=10
peer=""
resource="1G_file"
localip=""
joblog="/tmp/joblog"
while [[ $# > 0 ]] ; do
    key="$1"
    shift
    case $key in
        -c|--count)
            count=$1
            shift
            ;;
        -p|--peer)
            peer=$1
            shift
            ;;
        -r|--resource)
            resource=$1
            shift
            ;;
        -b|--bind)
            localip="--bind-address=$1"
            shift
            ;;
        -j|--joblog)
            joblog=$1
            shift
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z "$peer" ]] ; then
    usage
fi

echo "Working with:"
echo "  count: $count"
echo "  peer:  $peer"
echo "  local: $localip"
echo "  resource: $resource"
echo "  cmd:  ${cmd}"
echo "  joblog:  ${joblog}"

echo "Starting parallel job"
parallel -j${count} --joblog ${joblog} -N0 wget ${localip} http://${pip}/${resource} -q -O /dev/null ::: $(seq 1 ${count})
cat ${joblog}

