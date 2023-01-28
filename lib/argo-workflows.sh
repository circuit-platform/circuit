#!/bin/bash

ARGO_WORKFLOWS_NAMESPACE="argo"
ARGO_WORKFLOWS_VERSION="v3.4.4"

argo_workflows_start() {
	kubectl create namespace ${ARGO_WORKFLOWS_NAMESPACE} 
	kubectl apply -n ${ARGO_WORKFLOWS_NAMESPACE} -f https://github.com/argoproj/argo-workflows/releases/download/${ARGO_WORKFLOWS_VERSION}/install.yaml
	kubectl patch svc argo-server -n ${ARGO_WORKFLOWS_NAMESPACE} -p '{"spec": {"type": "LoadBalancer"}}'

}

argo_workflows_stop() {
	kubectl delete namespace ${ARGO_WORKFLOWS_NAMESPACE}
}

argo_workflows_restart() {
	argo_workflows_stop
	sleep 5s
	argo_workflows_start
}

argo_workflows_config() {
	kubectl -n ${ARGO_WORKFLOWS_NAMESPACE} apply -f ${BASE_PATH}/etc/secrets/minio.yaml

	TMP_FILE=$(mktemp)
	kubectl get configmap workflow-controller-configmap -n ${ARGO_WORKFLOWS_NAMESPACE} -o yaml > ${TMP_FILE}
	cat ${BASE_PATH}/etc/conf/argo-workflows/artifact_repository.yaml >> ${TMP_FILE}
	kubectl -n ${ARGO_WORKFLOWS_NAMESPACE} apply -f ${TMP_FILE}

	MINIO_URL=$(minikube_url default argo-artifacts)

	echo $MINIO_URL

	aws configure set default.s3.signature_version s3v4

	while : ; do
    	aws --endpoint-url ${MINIO_URL} s3 mb s3://argo-workflow-artifacts 2> /dev/null
    	[[ $? -ne 0 ]] || break
    	sleep 10s
	done
}