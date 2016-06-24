FROM debian:jessie-backports
MAINTAINER Fabio Rauber <fabiorauber@gmail.com>

ENV PDNS_LAUNCH="gmysql" \
    PDNS_GMYSQL_HOST="mysql" \
    PDNS_GMYSQL_USER='$MYSQL_ENV_MYSQL_USER' \
    PDNS_GMYSQL_DBNAME='$MYSQL_ENV_MYSQL_DATABASE' \
    PDNS_GMYSQL_PASSWORD='$MYSQL_ENV_MYSQL_PASSWORD' \
    PDNS_INCLUDE_DIR="/etc/powerdns/pdns.d" \
    PDNS_GMYSQL_DNSSEC="yes" \
    PDNS_EXPERIMENTAL_API_KEY=""

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y -t jessie-backports pdns-server pdns-backend-mysql mysql-client && \
    rm /etc/powerdns/pdns.d/*.conf && rm /etc/powerdns/*.conf && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 53/udp 53/tcp

ADD start.sh /usr/local/bin/start.sh
RUN chmod a+x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]
