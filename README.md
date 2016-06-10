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
  image: interlegis/powerdns
  links:
    - "mysql:mysql"
  ports:
    - "53:53"
    - "53:53/udp"
mysql:
  image: mysql
  environment:
    - MYSQL_ROOT_PASSWORD=mysqlrootpw
    - MYSQL_DATABASE=pdns
    - MYSQL_USER=pdns
    - MYSQL_PASSWORD=pdnspw
```

## Running

```
cd <folder where docker-compose.yaml is>
docker-compose up -d
```

## Contributing

Pull requests welcome!
                          
