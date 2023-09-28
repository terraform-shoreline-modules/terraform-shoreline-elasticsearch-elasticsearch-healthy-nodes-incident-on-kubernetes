bash

#!/bin/bash



# Define the name of the Elasticsearch deployment and the number of replicas

deployment_name=${DEPLOYMENT_NAME}

replica_count=${REPLICA_COUNT}



# Get the current number of replicas

current_replicas=$(kubectl get deployment $deployment_name -o=jsonpath="{.spec.replicas}")



# If the current number of replicas is less than the desired replica count, scale up the deployment

if [ "$current_replicas" -lt "$replica_count" ]; then

    kubectl scale deployment $deployment_name --replicas=$replica_count

fi