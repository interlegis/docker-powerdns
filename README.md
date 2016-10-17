# docker-powerdns
PowerDNS docker container, based on Debian Jessie.

## Requirements

### Docker

To use this image you need docker daemon installed. Run the following commands as root:

```
curl -ssl https://get.docker.com | sh
```

### Docker-compose

Docker-compose is desirable (run as root as well):

```
curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
```

## Docker-compose Example

Save the following snippet as docker-compose.yaml in any folder you like, or clone this repository, which contains the same file.

```
pdns:
  image: interlegis/powerdns:4.0.1-1
  links:
    - "mysql:mysql"
  ports:
    - "53:53"
    - "53:53/udp"
    - "8088:8081"
  environment:
    - PDNSCONF_API_KEY=a_strong_api_key
    - PDNSCONF_MASTER=yes
    - PDNSCONF_DEFAULT_SOA_NAME=dnsserver.domain.com

mysql:
  image: mysql
  environment:
    - MYSQL_ROOT_PASSWORD=mysqlrootpw
    - MYSQL_DATABASE=pdns
    - MYSQL_USER=pdns
    - MYSQL_PASSWORD=pdnspw
```

## Environment Variables Supported

Any setting from https://doc.powerdns.com/3/authoritative/settings/ is supported. Just add the prefix "PDNS\_" and replace any hyphens (-) with underscore (\_). Example: 

``` allow-axfr-ips ===> PDNS_ALLOW_AXFR_IPS ```

### Additional Environment Variables:

 - SECALLZONES_CRONJOB: If set to 'yes', a Cron Job every half hour checks if any domain is not DNSSEC enabled. If so, it enables DNSSEC for that zone and fixes any DS records in parent zones hosted in the same server.

## Clustering

You can easily enable PowerDNS native "slaves" with bitnami/mariadb docker image. 
See <https://hub.docker.com/r/bitnami/mariadb>

## Running

```
cd <folder where docker-compose.yaml is>
docker-compose up -d
```

## Contributing

Pull requests welcome!
