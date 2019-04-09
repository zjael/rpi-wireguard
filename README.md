# Example

Will automatically generate keys on startup for:
* server_public_key
* server_private_key
* client_public_key
* client_private_key

## wg0.conf
```
[Interface]
Address = 192.168.0.1
PrivateKey = server_private_key
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o wlan0 -j MASQUERADE

[Peer]
PublicKey = client_public_key
AllowedIPs = 192.168.0.2/32
```

## peer.conf
```
[Interface]
Address = 192.168.0.2
PrivateKey = client_private_key
DNS = 192.168.10.10, 1.1.1.1

[Peer]
PublicKey = server_public_key
Endpoint = external.domain.or.ip:51820

# Forward all traffic through VPN
AllowedIPs = 0.0.0.0/0, ::/0

# If behind NAT or a firewall and want receive incoming connections after network traffic has gone silent
PersistentKeepalive = 25
```

# Usage
Store config files at /etc/wireguard

```bash
docker run -it --network host --cap-add net_admin --cap-add sys_module \
  -v /etc/wireguard:/etc/wireguard -v /lib/modules:/lib/modules -v /usr/src:/usr/src \
  zjael/rpi-wireguard:latest
```

# Connect
Option 1.
- Copy peer.conf to device

Option 2.
- Generate QR code with qrencode:
  - apt install qrencode
  - qrencode -t ansiutf8 < peer.conf
  - scan QR code with device