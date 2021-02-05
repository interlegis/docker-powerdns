# docker-powerdns
PowerDNS docker container, based on Debian Buster.

## Requirements

### Docker

To use this image you need docker daemon installed. Run the following commands as root:

```
curl -ssl https://get.docker.com | sh
```

### Docker-compose

Docker-compose is desirable (run as root as well):

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

## Docker-compose Example

Save the following snippet as docker-compose.yaml in any folder you like, or clone this repository, which contains a sample docker-compose.yml.

```
pdns:
  image: interlegis/powerdns:4.4.0
  links:
    - "mysql:mysql"
  ports:
    - "53:53"
    - "53:53/udp"
    - "8088:8081"
  environment:
    - PDNSCONF_API_KEY=a_strong_api_key

mysql:
  image: mysql
  environment:
    - MYSQL_ROOT_PASSWORD=mysqlrootpw
    - MYSQL_DATABASE=pdns
    - MYSQL_USER=pdns
    - MYSQL_PASSWORD=pdnspw
```

## Environment Variables Supported

Any setting from https://doc.powerdns.com/authoritative/settings.html is supported. Just add the prefix "PDNS\_" and replace any hyphens (-) with underscore (\_). Example: 

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
