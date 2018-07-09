#!/bin/bash

echo "[`date +"%T"`] Secallzones starting... "
ZONES=`pdnsutil list-all-zones | grep -v "All zonecount"`
while read -r d; do
  pdnsutil show-zone $d | grep presigned >/dev/null 2>&1
  if [ $? -eq 0 ] ; then
    echo "Securing $d..."
    pdnsutil unset-presigned $d
    pdnsutil secure-zone $d
    pdnsutil rectify-zone $d
    fixdsrrs.sh -d $d
  else
    pdnsutil show-zone $d | grep "not actively secured" >/dev/null 2>&1
    if [ $? -eq 0 ] ; then
      echo "Securing $d..."
      pdnsutil secure-zone $d
      pdnsutil rectify-zone $d
      fixdsrrs.sh -d $d
    fi
  fi

done <<< "$ZONES"

echo -n "[`date +"%T"`] Rectifying all zones..."
pdnsutil rectify-all-zones &> /dev/null && echo " OK."

echo "[`date +"%T"`] Secallzones finished."


