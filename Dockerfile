FROM debian:latest

RUN apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends \
        openvswitch-switch \
        iproute2 \
        iperf3 \
        iputils-ping \
        net-tools \
 && rm -rf /var/lib/apt/lists/*
COPY start-ovs.sh /usr/local/bin/start-ovs.sh
RUN chmod +x /usr/local/bin/start-ovs.sh

CMD ["/usr/local/bin/start-ovs.sh"]
