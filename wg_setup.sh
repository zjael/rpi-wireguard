#!/bin/bash
set -e
interface='wg0'

git clone https://github.com/WireGuard/WireGuard.git
cd WireGuard/src
make
make install
modprobe wireguard

cd /etc/wireguard/
while ! [ -f $interface.conf ] && [ -f peer.conf ];
do
    echo "$(date): Waiting for $interface.conf and peer.conf"
    sleep 30
done

wg genkey | tee server_private.key | wg pubkey > server_public.key
wg genkey | tee client_private.key | wg pubkey > client_public.key

sed -i "s/server_private_key/$(sed 's:/:\\/:g' server_private.key)/" $interface.conf
sed -i "s/client_public_key/$(sed 's:/:\\/:g' client_public.key)/" $interface.conf
sed -i "s/client_private_key/$(sed 's:/:\\/:g' client_private.key)/" peer.conf
sed -i "s/server_public_key/$(sed 's:/:\\/:g' server_public.key)/" peer.conf

echo "$(date): Starting Wireguard"
wg-quick up $interface
systemctl enable wg-quick@$interface.service
qrencode -t ansiutf8 < peer.conf

finish () {
    echo "$(date): Shutting down Wireguard"
    wg-quick down $interface
    exit 0
}
trap finish SIGTERM SIGINT SIGQUIT

sleep infinity