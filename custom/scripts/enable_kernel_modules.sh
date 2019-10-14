#!/bin/bash
#
# Set PATH to find iptables
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/syno/sbin:/usr/syno/bin

# modules needed
KERNEL_MODULES=(x_tables.ko xt_addrtype.ko xt_comment.ko xt_geoip.ko xt_iprange.ko xt_limit.ko xt_LOG.ko xt_mac.ko xt_mark.ko xt_multiport.ko xt_NFQUEUE.ko xt_recent.ko xt_TCPMSS.ko xt_tcpudp.ko vxlan.ko veth.ko tun.ko tunnel4.ko nf_conntrack.ko nf_conntrack_proto_gre.ko nf_defrag_ipv4.ko nf_defrag_ipv6.ko nf_nat.ko nf_nat_masquerade_ipv4.ko nf_nat_proto_gre.ko nf_nat_redirect.ko nfnetlink.ko nfnetlink_queue.ko macvlan.ko ip6_tables.ko ip6_udp_tunnel.ko ip_set.ko ip_tables.ko ipt_MASQUERADE.ko ip_tunnel.ko ipv6.ko gre.ko bonding.ko stp.ko bridge.ko br_netfilter.ko xt_conntrack.ko xt_nat.ko xt_REDIRECT.ko xt_set.ko xt_state.ko nf_conntrack_ipv4.ko nf_conntrack_ipv6.ko nf_conntrack_pptp.ko nf_nat_ipv4.ko nf_nat_pptp.ko ip6table_filter.ko ip6table_mangle.ko ip_set_hash_ip.ko iptable_filter.ko iptable_mangle.ko iptable_nat.ko 8021q.ko nf_reject_ipv4.ko ipt_REJECT.ko)


start() {
    # Log execution time
    date

    # Make sure packet forwarding is enabled.
    # 'sysctl -w net.ipv4.ip_forward=1' does not work for me
    echo 1 > /proc/sys/net/ipv4/ip_forward

    # Count the number of modules so that we can verify if the module
    # insertion was successful. We replace whitespaces with newlines
    # and count lines.
    MODULE_COUNT=$(
        echo "${KERNEL_MODULES}" |
            gawk '{ print gensub(/\s+/, "\n", "g") }' |
            wc -l
    )

    # Load the kernel modules necessary for K3S
	for module in ${KERNEL_MODULES[@]}; do
		/sbin/insmod /lib/modules/$module
	done

    # Log current nat table
    iptables -L -v 
    iptables -L -v -t nat
}

case "$1" in
        start)
                start
                exit
                ;;
        stop)
		        exit
		        ;;
*)
                # Help message.
                echo "Usage: $0 start"
                exit 1
                ;;
esac
