sudo ip link set enp2s0 down
sudo ip addr add 192.168.2.1/24 dev enp2s0
sudo ip link set enp2s0 up
