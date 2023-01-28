#!/bin/bash

MODELS_NAMESPACE="services"
MODELS_DATABASES_NAMESPACE="databases"

models_build() {
	MODELS_PATH=${BASE_PATH}/models

	eval $(minikube docker-env)
	for model_name in $(ls ${MODELS_PATH}) ; do
		cd ${MODELS_PATH}/${model_name}/
		docker build -f ${MODELS_PATH}/${model_name}/Dockerfile -t ${MAIN_SPACE}/models/${model_name}:latest .
		cd -
	done
}

models_start_databases() {
	MODELS_PATH=${BASE_PATH}/models

	kubectl create namespace ${MODELS_DATABASES_NAMESPACE}

	eval $(minikube docker-env)
	for model_name in $(ls ${MODELS_PATH}) ; do
		MODEL_NAME=$model_name
		kubectl -n ${MODELS_DATABASES_NAMESPACE} apply -f $(file_template ${BASE_PATH}/etc/conf/models/database.yaml)
	done

	while [[ $(kubectl -n ${MODELS_DATABASES_NAMESPACE} get pods -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == *"False"* ]]; do
		sleep 5s
	done

	sleep 25s

	eval $(minikube docker-env)
	for model_name in $(ls ${MODELS_PATH}) ; do
		SQL_FILE=${MODELS_PATH}/${model_name}/sql/${model_name}.sql
		DB_POD=$(kubectl -n ${MODELS_DATABASES_NAMESPACE} get pods --selector=app=${model_name}-db --output=jsonpath={.items..metadata.name})

		kubectl -n ${MODELS_DATABASES_NAMESPACE} exec -i ${DB_POD} psql postgres://admin:admin@localhost < $(file_template ${BASE_PATH}/etc/sql/init.sql)
		kubectl -n ${MODELS_DATABASES_NAMESPACE} exec -i ${DB_POD} psql postgres://admin:admin@localhost/${MAIN_SPACE} < $(file_template ${SQL_FILE})
	done
}

models_start_services() {
	MODELS_PATH=${BASE_PATH}/models

	kubectl create namespace ${MODELS_NAMESPACE}

	eval $(minikube docker-env)
	for model_name in $(ls ${MODELS_PATH}) ; do
		MODEL_NAME=$model_name
		DOCKER_IMAGE=${MAIN_SPACE}/models/${model_name}:latest
		DB_SOURCE="postgres://admin:admin@${model_name}-db.databases/${MAIN_SPACE}?sslmode=disable"
		KAFKA_SOURCE="broker.kafka:9092"
		kubectl -n ${MODELS_NAMESPACE} apply -f $(file_template ${BASE_PATH}/etc/conf/models/service.yaml)
	done	
}

models_configure_debezium() {
	MODELS_PATH=${BASE_PATH}/models

	for model_name in $(ls ${MODELS_PATH}) ; do
		MODEL_NAME=$model_name
		NAMESPACE=$MODELS_DATABASES_NAMESPACE
		CONNECT_URL=$(minikube_url debezium connect)

		curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" ${CONNECT_URL}/connectors/ -d @$(file_template ${BASE_PATH}/etc/conf/models/debezium.json)
	done
}

models_unconfigure_debezium() {
	echo "TBD"
}

models_stop_databases() {
	kubectl delete namespace ${MODELS_DATABASES_NAMESPACE}
}

models_stop_services() {
	kubectl delete namespace ${MODELS_NAMESPACE}
}


models_start() {
	models_start_databases
	models_configure_debezium
	models_start_services
}

models_stop() {
	models_stop_services
	models_unconfigure_debezium
	models_stop_databases
}

file_template() {
	TEMPLATE=$1
	FILE=$(mktemp)

	eval "cat <<< \"$(cat ${TEMPLATE} | sed 's/\"/\\\"/g')\"" > ${FILE}

	echo ${FILE}
}