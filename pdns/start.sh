#!/bin/bash

mkdir -p /etc/powerdns

cat >/etc/powerdns/pdns.conf <<EOF
# MySQL Configuration
#
# Launch gmysql backend
launch=gmysql
# gpgsql parameters
gmysql-host=mysql
gmysql-user=$MYSQL_ENV_MYSQL_USER
gmysql-dbname=$MYSQL_ENV_MYSQL_DATABASE
gmysql-password=$MYSQL_ENV_MYSQL_PASSWORD
gmysql-dnssec=yes
EOF

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