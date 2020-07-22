#!/bin/bash

MODELS_NAMESPACE="services"
MODELS_DATABASES_NAMESPACE="databases"

models_build() {
	MODELS_PATH=${BASE_PATH}/models

	eval $(minikube docker-env)
	for model_name in $(ls ${MODELS_PATH}) ; do
		cd ${MODELS_PATH}/${model_name}/
		docker build -f ${MODELS_PATH}/${model_name}/Dockerfile -t circuit/models/${model_name}:latest .
		cd -
	done
}

models_start_databases() {
	MODELS_PATH=${BASE_PATH}/models

	kubectl create namespace ${MODELS_DATABASES_NAMESPACE}

	eval $(minikube docker-env)
	for model_name in $(ls ${MODELS_PATH}) ; do
		DATABASE_YAML=$(mktemp)

		MODEL_NAME=$model_name
		eval "cat <<< \"$(cat ${BASE_PATH}/etc/conf/models/database.yaml | sed 's/\"/\\\"/g')\"" > ${DATABASE_YAML}

		kubectl -n ${MODELS_DATABASES_NAMESPACE} apply -f ${DATABASE_YAML}
	done

	while [[ $(kubectl -n ${MODELS_DATABASES_NAMESPACE} get pods -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == *"False"* ]]; do
		sleep 5s
	done

	sleep 25s

	eval $(minikube docker-env)
	for model_name in $(ls ${MODELS_PATH}) ; do
		SQL_FILE=${MODELS_PATH}/${model_name}/sql/${model_name}.sql
		DB_POD=$(kubectl -n ${MODELS_DATABASES_NAMESPACE} get pods --selector=app=${model_name}-db --output=jsonpath={.items..metadata.name})

		kubectl -n ${MODELS_DATABASES_NAMESPACE} exec -i ${DB_POD} psql postgres://admin:admin@localhost < ${BASE_PATH}/etc/sql/init.sql
		kubectl -n ${MODELS_DATABASES_NAMESPACE} exec -i ${DB_POD} psql postgres://admin:admin@localhost/circuit < ${SQL_FILE}
	done
}

models_start_services() {
	MODELS_PATH=${BASE_PATH}/models

	kubectl create namespace ${MODELS_NAMESPACE}

	eval $(minikube docker-env)
	for model_name in $(ls ${MODELS_PATH}) ; do
		SERVICE_YAML=$(mktemp)

		MODEL_NAME=$model_name
		DOCKER_IMAGE=circuit/models/${model_name}:latest
		DB_SOURCE="postgres://admin:admin@${model_name}-db.databases/circuit?sslmode=disable"
		KAFKA_SOURCE="broker.kafka:9092"
		eval "cat <<< \"$(cat ${BASE_PATH}/etc/conf/models/service.yaml | sed 's/\"/\\\"/g')\"" > ${SERVICE_YAML}

		kubectl -n ${MODELS_NAMESPACE} apply -f ${SERVICE_YAML}
	done	
}

models_configure_debezium() {
	MODELS_PATH=${BASE_PATH}/models

	for model_name in $(ls ${MODELS_PATH}) ; do
		DEBEZIUM_JSON=$(mktemp)

		MODEL_NAME=$model_name
		NAMESPACE=$MODELS_DATABASES_NAMESPACE
		eval "cat <<< \"$(cat ${BASE_PATH}/etc/conf/models/debezium.json | sed 's/\"/\\\"/g')\"" > ${DEBEZIUM_JSON}

		CONNECT_URL=$(minikube -n debezium service --url connect)
		curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" ${CONNECT_URL}/connectors/ -d @${DEBEZIUM_JSON}
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