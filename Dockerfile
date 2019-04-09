FROM jsurf/rpi-raspbian:latest

RUN [ "cross-build-start" ]

# Build requirements
RUN apt-get update && apt-get install -y git libmnl-dev libelf-dev build-essential pkg-config raspberrypi-kernel-headers

# Application requirements
RUN apt-get install -y iptables iproute2 qrencode

RUN mkdir /scripts
ADD wg_setup.sh /scripts/wg_setup.sh
RUN chmod +x /scripts/wg_setup.sh

RUN [ "cross-build-end" ] 

ENTRYPOINT ["/scripts/wg_setup.sh"]
CMD []