#!/bin/bash

mkdir -p /etc/powerdns/pdns.d

PDNSVARS=`echo ${!PDNSCONF_*}`
touch /etc/powerdns/pdns.conf

for var in $PDNSVARS; do
  varname=`echo ${var#"PDNSCONF_"} | awk '{print tolower($0)}' | sed 's/_/-/g'`
  value=`echo ${!var} | sed 's/^$\(.*\)/\1/'`
  if [ ! -z ${!value} ]; then
    echo "$varname=${!value}" >> /etc/powerdns/pdns.conf
  else
    echo "$varname=$value" >> /etc/powerdns/pdns.conf
  fi
done

if [ ! -z $PDNSCONF_EXPERIMENTAL_API_KEY ]; then
  cat >/etc/powerdns/pdns.d/api.conf <<EOF
experimental-json-interface=yes
webserver=yes
webserver-address=0.0.0.0
webserver-allow-from=0.0.0.0/0
EOF

fi

mysqlcheck() {
  # Wait for MySQL to be available...
  COUNTER=20
  until mysql -h mysql -u $MYSQL_ENV_MYSQL_USER -p$MYSQL_ENV_MYSQL_PASSWORD -e "show databases" 2>/dev/null; do
    echo "WARNING: MySQL still not up. Trying again..."
    sleep 10
    let COUNTER-=1
    if [ $COUNTER -lt 1 ]; then
      echo "ERROR: MySQL connection timed out. Aborting."
      exit 1
    fi
  done

  count=`mysql -h mysql -u $MYSQL_ENV_MYSQL_USER -p$MYSQL_ENV_MYSQL_PASSWORD -e "select count(*) from information_schema.tables where table_type='BASE TABLE' and table_schema='$MYSQL_ENV_MYSQL_DATABASE';" | tail -1`
  if [ "$count" == "0" ]; then
    echo "Database is empty. Importing PowerDNS schema..."
    mysql -h mysql -u $MYSQL_ENV_MYSQL_USER -p$MYSQL_ENV_MYSQL_PASSWORD $MYSQL_ENV_MYSQL_DATABASE < /usr/share/doc/pdns-backend-mysql/schema.mysql.sql && echo "Import done."
  fi
}

mysqlcheck

# Start PowerDNS
# same as /etc/init.d/pdns monitor
echo "Starting PowerDNS..."

if [ "$#" -gt 0 ]; then
  exec /usr/sbin/pdns_server "$@"
else
  exec /usr/sbin/pdns_server --daemon=no --guardian=no --control-console --loglevel=9
fi
