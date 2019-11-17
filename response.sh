#!/bin/bash

usage() {
    echo "response.sh [-c|--count N] [-r|--resouce url] [-b|--bind <localip>] -p|-peer <peer>"
    echo "    defaults:"
    echo "           --count     1"
    echo "           --resource  1K_file"
    echo "    peer is mandatory"
    exit 1
}

count=1
peer=""
resource="1B_file"
localip=""
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
        *)
            usage
            ;;
    esac
done

if [[ -z "$peer" ]] ; then
    usage
fi

cmd="wget ${localip} http://${pip}/${resource} -q -O /dev/null"
echo "Working with:"
echo "  count: $count"
echo "  peer:  $peer"
echo "  local: $localip"
echo "  resource: $resource"
echo "  cmd:  ${cmd}"

min=$(( (1<<32)-1 ))
max=1
avg=1
let total=count
while [ $count -gt 0 ]; do
    start=$(date +%s%N)
    eval $cmd
    let count=count-1
    end=$(date +%s%N)
    let response=end-start
    let response=response/1000000
    echo "$count response: $response"
    let array[$count]=response
    if [[ $response -lt $min ]]; then
        let min=response
    fi
    if [[ $response -gt $max ]]; then
        let max=response
    fi
    let avg=avg+response
done
let avg=avg/total
let count=total
deviation=0
while [ $count -gt 0 ]; do
    let diff=array[count-1]-avg
    let diff2=diff*diff
    let deviation=deviation+diff2
    let count=count-1
done
let deviation=deviation/total
echo "response (in ms) min:$min max:$max avg:$avg variance:$deviation"
