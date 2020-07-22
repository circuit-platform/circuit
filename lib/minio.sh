#!/bin/bash

AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

minio_start() {
	helm repo add stable https://kubernetes-charts.storage.googleapis.com/
	helm repo update
	helm install argo-artifacts stable/minio --set service.type=LoadBalancer --set fullnameOverride=argo-artifacts	
}