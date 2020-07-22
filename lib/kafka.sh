#!/bin/bash

KAFKA_NAMESPACE="kafka"

kakfa_start() {
	kubectl create namespace ${KAFKA_NAMESPACE}
	kubectl apply -k github.com/Yolean/kubernetes-kafka/variants/dev-small/?ref=v6.0.3
}

kafka_stop() {
	kubectl delete namespace ${KAFKA_NAMESPACE}
}

kafka_restart() {
	kafka_stop
	sleep 5s
	kakfa_start
}

kafka_list_topics() {
	kubectl -n ${KAFKA_NAMESPACE} exec -i kafka-0 -- /opt/kafka/bin/kafka-topics.sh \
		--bootstrap-server localhost:9092 \
		--list
}

kafka_stream() {
	kubectl -n ${KAFKA_NAMESPACE} exec -i kafka-0 -- /opt/kafka/bin/kafka-console-consumer.sh \
		--bootstrap-server kafka:9092 \
    	--from-beginning \
    	--property print.key=false \
    	--topic $1
}