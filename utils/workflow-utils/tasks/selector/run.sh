#!/bin/sh

set -e -x

export ITEMS_URL=http://$(host -t SRV ${ITEMS}.services.svc.cluster.local | sed -r 's/.+ ([^ ]+) ([^ ]+)\.$/\2:\1/g')/${ITEMS}
export NAMESPACES_URL=http://$(host -t SRV namespaces.services.svc.cluster.local | sed -r 's/.+ ([^ ]+) ([^ ]+)\.$/\2:\1/g')/namespaces

http GET ${ITEMS_URL} filter==${QUERY_FILTER} | items-enrich | jq ". | map(select(${FILTER}))" | tee /tmp/items.json

if [ $(jq '. | length' /tmp/items.json) -eq 0 ]; then
	exit 1
fi