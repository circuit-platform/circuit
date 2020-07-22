#!/bin/sh


configure-bash() {
	set -e
}

configure-env() {
	export NUM_GROUPS=10
	export INPUT_FILE="/tmp/items.json"
	export OUTPUT_FILE_TMPL="/tmp/items_%.5d.json"
}

split-mod() {
	OUTPUT_FILE_LIST=$(mktemp)
	for entry in $(cat $1 | jq -r '.[] | @base64'); do
		item=$(echo ${entry} | base64 -D)

		MD5=$(echo ${item} | jq -r '.id' | md5 | head -c 6)
		GROUP=$(( 0x${MD5} % ${NUM_GROUPS} ))


		OUTPUT_FILE=$(printf $2 ${GROUP})
		echo ${item} >> ${OUTPUT_FILE}

		echo ${OUTPUT_FILE} >> ${OUTPUT_FILE_LIST}
	done

	for OUTPUT_FILE in $(sort -u ${OUTPUT_FILE_LIST}); do
		jq -s '.' ${OUTPUT_FILE} | tee ${OUTPUT_FILE}.tmp
		mv ${OUTPUT_FILE}.tmp ${OUTPUT_FILE}
	done
}

main() {
	configure-bash
	configure-env

	split-mod ${INPUT_FILE} ${OUTPUT_FILE_TMPL}
}
	
main