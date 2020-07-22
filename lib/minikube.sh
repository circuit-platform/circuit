#!/bin/bash

MINIKUBE_ARGS="--container-runtime=docker --cpus 2 --memory 8192 --vm-driver=virtualbox"

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