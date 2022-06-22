FROM debian:bullseye

MAINTAINER Fabio Rauber <fabiorauber@gmail.com>

ENV PDNSCONF_LAUNCH="gmysql" \
    PDNSCONF_GMYSQL_HOST="mysql" \
    PDNSCONF_GMYSQL_USER='' \
    PDNSCONF_GMYSQL_DBNAME='' \
    PDNSCONF_GMYSQL_PASSWORD='' \
    PDNSCONF_INCLUDE_DIR="/etc/powerdns/pdns.d" \
    PDNSCONF_GMYSQL_DNSSEC="yes" \
    PDNSCONF_API_KEY="" \
    SECALLZONES_CRONJOB="no"

ADD https://repo.powerdns.com/FD380FBB-pub.asc /etc/apt/trusted.gpg.d/powerdns-key.asc

ADD pdns.list /etc/apt/sources.list.d/pdns.list
ADD pdns.preference /etc/apt/preferences.d/pdns 

RUN chmod 644 /etc/apt/trusted.gpg.d/powerdns-key.asc && \
    apt-get update && \
    echo "path-include /usr/share/doc/*/*.sql" >> /etc/dpkg/dpkg.cfg.d/docker && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y pdns-server pdns-backend-mysql mariadb-client && \
    rm /etc/powerdns/pdns.d/*.conf && rm /etc/powerdns/*.conf && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends cron curl jq busybox && \
    rm /etc/cron.daily/* && \
    mkdir /var/run/pdns && \
    ln -s /bin/busybox /usr/bin/nslookup && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 53/udp 53/tcp

ADD start.sh /usr/local/bin/start.sh
ADD fixdsrrs.sh /usr/local/bin/fixdsrrs.sh
ADD secallzones.sh /usr/local/bin/secallzones.sh
RUN chmod a+x /usr/local/bin/*.sh

CMD ["/usr/local/bin/start.sh"]
