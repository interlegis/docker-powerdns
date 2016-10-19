#!/bin/bash

APISERVER="http://localhost:8081"

INVALIDARG=0
while getopts "d:" opt; do
    case "$opt" in
    d)  ZONES="$OPTARG."
        ;;
    *)  INVALIDARG=1
        ;;
    esac
done

if [ $INVALIDARG == 1 ]; then
    echo "EXITING: Invalid argument!"
    exit 1
fi


if [ -z "$ZONES" ]; then
  ZONES=`curl -s -X GET -H "X-API-Key: $PDNSCONF_API_KEY" $APISERVER/api/v1/servers/localhost/zones | jq -c '.[] | .id' | sed -e 's/"//g'`
fi
 
while read -r d; do
  IFS='. ' read -r -a dcs <<< "$d"
  NODCS="${#dcs[@]}"
  if [ $NODCS -gt 3 ]; then
    # $d is not a top domain
    TOPDOM="${dcs[-3]}.${dcs[-2]}.${dcs[-1]}."
    # get current DNS for $d
    CURRDSRAW=`curl -s -f -X GET --data '{"rrsets": [ { "name": "'"$TOPDOM"'." } ] }' -H "X-API-Key: $PDNSCONF_API_KEY" $APISERVER/api/v1/servers/localhost/zones/$TOPDOM`
    if [ $? -ne 0 ]; then
      echo "Domain $TOPDOM does not exist in this server. Skipping $d.."
      continue
    fi
    CURRDS=`echo $CURRDSRAW | jq -c '[ .rrsets[] | select( .type ==  "DS" ) | select ( .name == "'$d'"
) ][0]["records"][0]["content"]'`
    # get DS that should have been configured
    CORRDS=`curl -s -X GET -H "X-API-Key: $PDNSCONF_API_KEY" $APISERVER/api/v1/servers/localhost/zones/$d/cryptokeys | jq -c '.[] | select( .keytype == "csk") ["ds"][0] '`
    if [ "$CURRDS" != "$CORRDS" ]; then
      echo -n "INFO: Fixing $d DS records..."
      curl -s -X PATCH --data '{"rrsets": [ {"name": "'$d'", "type": "DS", "changetype": "REPLACE", "ttl": "86400", "records": [ {"content": '"$CORRDS"', "disabled": false, "name": "'$d'", "ttl": 86400, "type": "DS", "priority": 0 } ] } ] }' -H "X-API-Key: $PDNSCONF_API_KEY" $APISERVER/api/v1/servers/localhost/zones/$TOPDOM | jq . && echo " OK."
    fi 
  fi
done <<< "$ZONES"
