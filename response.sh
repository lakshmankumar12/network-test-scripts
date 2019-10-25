#!/bin/bash

usage() {
    echo "response.sh [-c|--count N] [-r|--resouce url] -p|-peer <peer>"
    echo "    defaults:"
    echo "           --count     1"
    echo "           --resource  1G_file"
    echo "    peer is mandatory"
    exit 1
}

count=1
peer=""
resource="1G_file"
while [[ $# > 0 ]] ; do
    key="$1"
    shift
    case $key in
        -c|--count)
            count=$2
            shift
            ;;
        -p|--peer)
            peer=$2
            shift
            ;;
        -r|--resource)
            resource=$2
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

min=600
max=1
avg=1
let total=count
while [ $count -gt 0 ]; do
        start=$(date +%s%N)
        wget http://${pip}/${resource} -q -O /dev/null
        let count=count-1
        end=$(date +%s%N)
        let response=end-start
        let response=response/1000000
        echo "$count response: $response"
        let array[$count]=response
        if [[ $response -lt $min ]]; 
        then
                let min=response
        fi
        if [[ $response -gt $max ]];
        then
                let max=response
        fi
        let avg=avg+response
        #sleep 50
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
#echo "response min:$min max:$max avg:$avg variance:$deviation" >> response_time.txt
echo "response min:$min max:$max avg:$avg variance:$deviation"
