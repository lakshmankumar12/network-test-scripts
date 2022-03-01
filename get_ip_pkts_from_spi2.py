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
    outfile = PcapWriter(options.outfile);
    with PcapReader(options.infile) as pcap_reader:
        for pkt in pcap_reader:
            b=bytes(pkt)
            if b[20] == 0x45:
                opkt=IP(b[20:])
                opkt.time=pkt.time
                outfile.write(opkt)

options = get_args()
main(options)
