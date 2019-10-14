#!/bin/bash
start(){
	i="0"

	while [ $i -lt 10 ]
	do
	    /sbin/ip r | grep "10.42.0.0/24 dev cni0  scope link" > /dev/null 2>&1
		if [ $? -eq 0 ]; then
            echo "cni0 route present"
            exit 0
        fi
		echo "route not already present. check $i time"
		i=$[$i+1]
        sleep 10
	done
    echo "cni0 route check timeout. force insert"
    /sbin/ip r add 10.42.0.0/24 dev cni0    
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
				echo "Usage: $0 start stop"
				exit 1
				;;
esac

