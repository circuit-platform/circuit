#!/bin/bash

set -x

BASE_PATH=$(realpath $(dirname $(realpath $0))/..)

source ${BASE_PATH}/etc/circuit.conf
for f in ${BASE_PATH}/lib/* ; do source $f; done

start() {
	minikube_start
	kakfa_start
	debezium_start
	minio_start
	argo_workflows_start
	argo_workflows_config
	argo_events_start
	workflow_utils_build
	workflow_utils_load
	models_build
	models_start
}

stop() {
	minikube_stop
}

status() {
	minikube service list
}

case "$1" in
    'start')
            start
            ;;
    'stop')
            stop
            ;;
    'restart')
            stop ; echo "Sleeping..."; sleep 1 ;
            start
            ;;
    'status')
            status
            ;;
    *)
            echo
            echo "Usage: $0 { start | stop | restart | status }"
            echo
            exit 1
            ;;
esac