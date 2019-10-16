#!/bin/bash
#
# Set PATH 
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/syno/sbin:/usr/syno/bin:/volume1/k3s/data/d4f98b2da1abb7c68677600aa20f0b207b7bd6614825307f0c6684cb84a6abed/bin

start() {
    sleep 3
	echo "starting k3s"
	/volume1/k3s/k3s-arm64 server -d /volume1/k3s/ --log /volume1/k3s/logs/k3s.log --kubelet-arg=eviction-hard=memory.available\<100Mi --kubelet-arg=eviction-hard=nodefs.available\<2Gi --kubelet-arg=eviction-hard=nodefs.inodesFree\<5\% --kubelet-arg=image-gc-high-threshold=100 --kubelet-arg=image-gc-low-threshold=99 &
}

stop() {
	echo "stopping k3s"
	kill $(ps ef |grep k3s-server |awk '{print $1}')
	sleep 3

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
