# TcpTester

Uses scapy to build tcp pkts.

# Usage






# Internals

Ideally there is a Manager class and a per-connection Connection class.
But since we need to setup libpcap sniffing rule on a per-connection basis, the manager manages one connection only. To support multiple connection, there is work on setting up sniffer and the way to getNextPkt for interested connection.

There is a sniffer thread and keeps sniffing and enqueuing pkts into Manager.pktQueue. The getNextPacket collects the next pkt off the Manager's queue.

The Connection class has distinct api's fine-tuned to run for client/server.

For now, args control whether to run as client/server.

# To run as client


