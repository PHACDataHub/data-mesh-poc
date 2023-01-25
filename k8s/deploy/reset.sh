#!/bin/bash

kubectl delete --all deployments --namespace=default
kubectl delete --all jobs --namespace=default
kubectl delete --all pvc --namespace=default

