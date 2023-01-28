#!/bin/bash

#MINIKUBE_ARGS="--container-runtime=docker --cpus 2 --memory 8192 --driver=podman"
MINIKUBE_ARGS="--driver=docker --alsologtostderr"

minikube_start() {
	minikube start ${MINIKUBE_ARGS}
}

minikube_stop() {
	minikube stop && minikube delete
}

minikube_restart() {
	minikube_stop
	sleep 5s
	minikube_start
}

minikube_url() {
	TMP_FILE=$(mktemp)

	#URL=$(minikube -n ${1} service --url ${2})
	nohup minikube -n ${1} service --url ${2} > ${TMP_FILE} &
	sleep 5s
	URL=$(cat ${TMP_FILE} | head -n 1)

	echo ${URL}
}
