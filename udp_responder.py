#!/bin/python

import threading
import queue

from scapy.all import *
from scapy.layers.inet import *

from argparse import Namespace as NS
from argparse import ArgumentParser

DEF_SRC_IP='192.168.122.92'
DEF_DST_IP='192.168.122.90'
DEF_SPORT='20000'
DEF_DPORT='19999'
DEF_IFC='mytunifc'
DEF_FILTER=f'udp dst port {DEF_SPORT}'
DEF_REPLY_SIZE=100
IP_AND_UDP_SIZE=28  #ip(20)+udp(8)
BASE_REPLY_MSG_FMT='Your reply is sized {:5d}\n'
REPLY_HDR_SIZE=len(BASE_REPLY_MSG_FMT.format(100))
BASE_PKT_SIZE=IP_AND_UDP_SIZE+REPLY_HDR_SIZE
DF_FLAG=0x2

def setup_params(opts):
    a = dict()
    items = [ 'src', 'dst', 'sport', 'dport',
              'ifc', 'data' , 'filter',
              'keep_sniffing', 'queue', 'replysize',
              'setdf' ]
    for i in items:
        a[i] = i
    params = NS(**a)
    params.src = opts.srcip
    params.dst = opts.dstip
    params.sport = int(opts.sport)
    params.dport = int(opts.dport)
    params.ifc = opts.ifc
    params.filter = opts.filter
    params.keep_sniffing = 1
    params.queue = queue.Queue()
    params.replysize = int(opts.replysize) - BASE_PKT_SIZE
    params.setdf = opts.setdf
    print ("Params is %s", params)
    return params

def background_sniffer_thread(params):
    print ("filter string is {}".format(params.filter))
    while params.keep_sniffing:
        pkt = sniff(iface=params.ifc, filter=params.filter, timeout=2)
        if pkt:
            for p in pkt:
                params.queue.put(p)
        else:
            #print("Nothing sniffed")
            pass

def build_pkt(pkt, params):
    dport = pkt[IP][UDP].sport
    flags = 0
    if params.setdf:
        flags |= DF_FLAG
    ip=IP(src=params.src,dst=params.dst,flags=flags)
    udp=UDP(sport=params.sport, dport=dport)
    payload = BASE_REPLY_MSG_FMT.format(params.replysize+BASE_PKT_SIZE)
    payload += "A"*params.replysize
    pkt = ip/udp/Raw(payload)
    send(pkt, iface=params.ifc)

def parse_args():
    parser = ArgumentParser()
    parser.add_argument("-s", "--srcip", help="srcip", default=DEF_SRC_IP)
    parser.add_argument("-d", "--dstip", help="srcip", default=DEF_DST_IP)
    parser.add_argument("-S", "--sport", help="srcip", default=DEF_SPORT)
    parser.add_argument("-D", "--dport", help="srcip", default=DEF_DPORT)
    parser.add_argument("-i", "--ifc", help="srcip", default=DEF_IFC)
    parser.add_argument("-f", "--filter", help="filter", default=DEF_FILTER)
    parser.add_argument(      "--setdf", help="filter", action="store_true")
    parser.add_argument(      "--replysize", help="filter", default=DEF_REPLY_SIZE)
    cmd_options = parser.parse_args()
    return cmd_options

def main():
    opts = parse_args()
    params = setup_params(opts)
    snifferthr = threading.Thread(target=background_sniffer_thread, args=(params,))
    snifferthr.start()
    while True:
        try:
            pkt = params.queue.get(block=True, timeout=10)
            build_pkt(pkt, params)
            print ("Got pkt:")
            pkt.show()
        except queue.Empty:
            pass

main()

