#!/bin/sh

txq_num="16"

func_stop() {
	for i in $(seq 0 $((txq_num - 1)))
	do
		if [ "${i}" -le $(((txq_num / 2) - 1)) ] ; then
			echo 0 0 0 0 0 0 4 > /sys/kernel/debug/hnat/qdma_txq$i
		else
			echo 1 0 0 0 0 0 4 > /sys/kernel/debug/hnat/qdma_txq$i
		fi
	done
	
	echo 0 sp 0 > /sys/kernel/debug/hnat/qdma_sch0
	echo 0 sp 0 > /sys/kernel/debug/hnat/qdma_sch1
	echo 0 0 0 0 0 0 4 > /sys/kernel/debug/hnat/qdma_txq0
	for i in $(seq 1 $((txq_num - 1)))
	do
		echo 0 0 0 0 0 0 0 > /sys/kernel/debug/hnat/qdma_txq$i
	done
	
	rmmod hw_nat
	modprobe hw_nat
	iptables -t mangle -D FORWARD -o br0 -j MARK --set-mark 6
	iptables -t mangle -D FORWARD -i br0 -j MARK --set-mark 14 
	iptables -t mangle -D FORWARD -o br0 -p udp -j MARK --set-mark 3
	iptables -t mangle -D FORWARD -i br0 -p udp -j MARK --set-mark 11
	iptables -t mangle -D POSTROUTING -o br0 -m dscp --dscp 2 -p udp -j MARK --set-mark 2
	iptables -t mangle -D POSTROUTING -o br0 -m dscp --dscp 2 -p tcp -j MARK --set-mark 2
	iptables -t mangle -D FORWARD -o br0 -p tcp --sport 1:65535 -m connlimit --connlimit-above 4 --connlimit-saddr -j MARK --set-mark 1 
	iptables -t mangle -D FORWARD -i br0 -p tcp --dport 1:65535 -m connlimit --connlimit-above 4 --connlimit-daddr -j MARK --set-mark 9 
	iptables -t mangle -D FORWARD -o br0 -p udp -m length --length :256 -j MARK --set-mark 7
	iptables -t mangle -D FORWARD -i br0 -p udp -m length --length :256 -j MARK --set-mark 15
	exit 0
}


 func_start(){
 
 	iptables -t mangle -D FORWARD -o br0 -j MARK --set-mark 6
	iptables -t mangle -D FORWARD -i br0 -j MARK --set-mark 14 
	iptables -t mangle -D FORWARD -o br0 -p udp -j MARK --set-mark 3
	iptables -t mangle -D FORWARD -i br0 -p udp -j MARK --set-mark 11
	iptables -t mangle -D POSTROUTING -o br0 -m dscp --dscp 2 -p udp -j MARK --set-mark 2
	iptables -t mangle -D POSTROUTING -o br0 -m dscp --dscp 2 -p tcp -j MARK --set-mark 2
	iptables -t mangle -D FORWARD -o br0 -p tcp --sport 1:65535 -m connlimit --connlimit-above 4 --connlimit-saddr -j MARK --set-mark 1 
	iptables -t mangle -D FORWARD -i br0 -p tcp --dport 1:65535 -m connlimit --connlimit-above 4 --connlimit-daddr -j MARK --set-mark 9 
	iptables -t mangle -D FORWARD -o br0 -p udp -m length --length :256 -j MARK --set-mark 7
	iptables -t mangle -D FORWARD -i br0 -p udp -m length --length :256 -j MARK --set-mark 15
        

	echo 0 sp $1 > /sys/kernel/debug/hnat/qdma_sch0
	echo 0 sp $2 > /sys/kernel/debug/hnat/qdma_sch1

	for i in $(seq 0 $((txq_num - 1)))
	do
		if [ "${i}" -le $(((txq_num / 2) - 1)) ] ; then
			echo 0 0 0 0 0 0 4 > /sys/kernel/debug/hnat/qdma_txq$i
		else
			echo 1 0 0 0 0 0 4 > /sys/kernel/debug/hnat/qdma_txq$i
		fi
	done
	
	
	dlmin=$(($1 * $3))
	dlmin=$((dlmin / 100))
	dlmax=$(($1 * 1))
	ulmin=$(($2 * $3))
	ulmin=$((ulmin / 100))
	ulmax=$(($2 * 1))
	
	for i in $(seq 0 $((txq_num - 1)))
	do
		if [ "${i}" -le $(((txq_num / 2) - 1)) ] ; then
			echo 0 1 "$dlmin" 1 "$dlmax" 0 4 > /sys/kernel/debug/hnat/qdma_txq$i
		else
			echo 1 1 "$ulmin" 1 "$ulmax" 0 4 > /sys/kernel/debug/hnat/qdma_txq$i
		fi
	done
	
	echo 1 sp $1 > /sys/kernel/debug/hnat/qdma_sch0
	echo 1 sp $2 > /sys/kernel/debug/hnat/qdma_sch1

	iptables -t mangle -A FORWARD -o br0 -j MARK --set-mark 6
	iptables -t mangle -A FORWARD -i br0 -j MARK --set-mark 14 
	iptables -t mangle -A FORWARD -o br0 -p udp -j MARK --set-mark 3
	iptables -t mangle -A FORWARD -i br0 -p udp -j MARK --set-mark 11
	iptables -t mangle -A POSTROUTING -o br0 -m dscp --dscp 2 -p udp -j MARK --set-mark 2
	iptables -t mangle -A POSTROUTING -o br0 -m dscp --dscp 2 -p tcp -j MARK --set-mark 2
	iptables -t mangle -A FORWARD -o br0 -p tcp --sport 1:65535 -m connlimit --connlimit-above 4 --connlimit-saddr -j MARK --set-mark 1 
	iptables -t mangle -A FORWARD -i br0 -p tcp --dport 1:65535 -m connlimit --connlimit-above 4 --connlimit-daddr -j MARK --set-mark 9
	iptables -t mangle -A FORWARD -o br0 -p udp -m length --length :256 -j MARK --set-mark 7
	iptables -t mangle -A FORWARD -i br0 -p udp -m length --length :256 -j MARK --set-mark 15
	rmmod hw_nat
	modprobe hw_nat
	exit 0	
}


case "$1" in
start)
	func_start $2 $3 $4
	;;
stop)
	func_stop
	;;
*)
	echo "Usage: $0 {start dl ul percentage(70) |stop}"
	exit 1
	;;
esac

