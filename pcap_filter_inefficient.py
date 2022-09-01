#!/usr/bin/python

from scapy.all import *
import argparse
import os

def get_args():

    parser = argparse.ArgumentParser(description="udpcon spi capture filter")

    parser.add_argument("-i", "--infile", help="input capture file", action="store", required=True)
    parser.add_argument("-o", "--outfile", help="output capture file", action="store", required=True)

    options = parser.parse_args()
    return options

def main(options):
    inpkts=rdpcap(options.infile)
    outlist=[]

    first_ip_pkt_found = False
    for pkt in inpkts:
        b=bytes(pkt)
        if b[20] == 0x45:
            opkt=IP(b[20:])
            opkt.time=pkt.time
            first_ip_pkt_found=True
        else:
            continue
        if first_ip_pkt_found:
            outlist.append(opkt)

    os.unlink(options.outfile)
    for pkt in outlist:
         wrpcap(options.outfile, pkt, append=True)


options = get_args()
main(options)
