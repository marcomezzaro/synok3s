#!/bin/bash
#
# Set PATH to find iptables
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/syno/sbin:/usr/syno/bin:/volume1/k3s/data/d4f98b2da1abb7c68677600aa20f0b207b7bd6614825307f0c6684cb84a6abed/bin


pstree() {
    for pid in $@; do
        echo $pid
        pstree $(ps -o ppid= -o pid= | awk "\$1==$pid {print \$2}")
    done
}

killtree() {
    [ $# -ne 0 ] && kill $(set +x; pstree $@; set -x)
}


do_unmount() {
    MOUNTS=$(cat /proc/self/mounts | awk '{print $2}' | grep "^$1" | sort -r)
    if [ -n "${MOUNTS}" ]; then
        umount ${MOUNTS}
    fi
}

start() {
    sleep 3
    echo "starting containerd"
    containerd -c /volume1/k3s/custom/config.toml  -a /run/k3s/containerd/containerd.sock --state /run/k3s/containerd --root /volume1/k3s/agent/containerd > /volume1/k3s/logs/containerd.log 2>&1 &
}

stop() {
	echo "stopping containerd"
	kill $(ps ef |grep "containerd -c /volume" |awk '{print $1}')
	sleep 3
    killtree $(lsof | sed -e 's/^[^0-9]*//g; s/  */\t/g' | grep -w 'containerd-shim' | cut -f1 | sort -n -u)
	do_unmount '/run/k3s'
    do_unmount '/run/netns'
    do_unmount '/var/lib/rancher/k3s'
	do_unmount '/volume1/k3s'
	/volume1/k3s/data/d4f98b2da1abb7c68677600aa20f0b207b7bd6614825307f0c6684cb84a6abed/bin/iptables -F
	/volume1/k3s/data/d4f98b2da1abb7c68677600aa20f0b207b7bd6614825307f0c6684cb84a6abed/bin/iptables -X
	/volume1/k3s/data/d4f98b2da1abb7c68677600aa20f0b207b7bd6614825307f0c6684cb84a6abed/bin/iptables -t nat -F
	/volume1/k3s/data/d4f98b2da1abb7c68677600aa20f0b207b7bd6614825307f0c6684cb84a6abed/bin/iptables -t nat -X

# TODO: disabled network removal
#	nets=$(ip link show | grep 'master cni0' | awk -F': ' '{print $2}' | sed -e 's|@.*||')
#	for iface in $nets; do
#	    ip link delete $iface;
#	done
}

case "$1" in
        start)
                start
                exit
                ;;
        stop)
		stop
		exit
	        ;;
	*)
                # Help message.
                echo "Usage: $0 start stop"
                exit 1
                ;;
esac
