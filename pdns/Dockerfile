FROM debian:jessie
MAINTAINER Fabio Rauber <fabiorauber@gmail.com>

ENV DNSSEC="yes" \
    APIKEY="" 

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y pdns-server pdns-backend-mysql mysql-client && \
    rm /etc/powerdns/pdns.d/*.conf && rm /etc/powerdns/*.conf && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 53/udp 53/tcp

ADD start.sh /usr/local/bin/start.sh
RUN chmod a+x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]
