#!/bin/sh

set -e

export ITEMS_URL=http://$(host -t SRV ${ITEMS}.services.svc.cluster.local | sed -r 's/.+ ([^ ]+) ([^ ]+)\.$/\2:\1/g')/${ITEMS}
export NAMESPACES_URL=http://$(host -t SRV namespaces.services.svc.cluster.local | sed -r 's/.+ ([^ ]+) ([^ ]+)\.$/\2:\1/g')/namespaces

for entry in $(cat /tmp/items.json | jq -r '.[] | @base64'); do
	item=$(echo ${entry} | base64 -d)
	
	echo $item | http POST ${ITEMS_URL}
done