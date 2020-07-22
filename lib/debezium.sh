#!/bin/bash

DEBEZIUM_NAMESPACE="debezium"

debezium_start() {
	kubectl create namespace ${DEBEZIUM_NAMESPACE}
	kubectl -n ${DEBEZIUM_NAMESPACE} apply -f ${BASE_PATH}/etc/conf/debezium.yaml
}

debezium_stop() {
	kubectl delete namespace ${DEBEZIUM_NAMESPACE}
}

debezium_restart() {
	debezium_stop
	sleep 5s
	debezium_start
}