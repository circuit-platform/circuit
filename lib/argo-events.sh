#!/bin/bash

ARGO_EVENTS_NAMESPACE="argo-events"
ARGO_EVENTS_VERSION="stable"

argo_events_start() {
	kubectl create namespace ${ARGO_EVENTS_NAMESPACE} 
	kubectl apply -n ${ARGO_EVENTS_NAMESPACE} -f https://raw.githubusercontent.com/argoproj/argo-events/${ARGO_EVENTS_VERSION}/manifests/install.yaml
}

argo_events_stop() {
	kubectl delete namespace ${ARGO_EVENTS_NAMESPACE}
}

argo_events_restart() {
	argo_events_stop
	sleep 5s
	argo_events_start
}