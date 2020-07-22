#!/bin/bash

workflow_utils_build() {
	WORKFLOW_UTILS_PATH=${BASE_PATH}/utils/workflow-utils

	eval $(minikube docker-env)
	for task_name in $(ls ${WORKFLOW_UTILS_PATH}/tasks) ; do
		cd ${WORKFLOW_UTILS_PATH}/tasks/${task_name}/
		docker build -f ${WORKFLOW_UTILS_PATH}/tasks/${task_name}/Dockerfile -t circuit/workflow-utils/tasks/${task_name}:lastest .
		cd -
	done
}

workflow_utils_load() {
	kubectl apply -f ${WORKFLOW_UTILS_PATH}/templates/workflow-utils.yaml
}
