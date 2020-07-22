#!/bin/sh

configure_bash() {
	set -e -x
}

configure_env() {
	export ITEMS_URL=http://$(host -t SRV ${ITEMS}.services.svc.cluster.local | sed -r 's/.+ ([^ ]+) ([^ ]+)\.$/\2:\1/g')/${ITEMS}
	export NAMESPACES_URL=http://$(host -t SRV namespaces.services.svc.cluster.local | sed -r 's/.+ ([^ ]+) ([^ ]+)\.$/\2:\1/g')/namespaces
	export PAYLOAD=$(echo ${EVENT} | jq -r .data | base64 -d | jq .payload)
}

main() {
	configure_bash
	configure_env

	OP=$(echo ${PAYLOAD} | jq -r .op)

	case $OP in
	"c")
		AFTER_ITEM=$(echo ${PAYLOAD} | jq -r .after)
		echo ${AFTER_ITEM} | jq '[.]' | items-enrich | jq ". | map(select(${FILTER}))" | tee /tmp/items.json
		;;
	*)
		exit 1
	esac

	if [ $(jq '. | length' /tmp/items.json) -eq 0 ]; then
		exit 1
	fi
}

main