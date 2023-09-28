

#!/bin/bash



# Set variables

NAMESPACE=${ELASTICSEARCH_NAMESPACE}

ELASTICSEARCH_POD_LABEL=${ELASTICSEARCH_POD_LABEL}

ELASTICSEARCH_CONTAINER_NAME=${ELASTICSEARCH_CONTAINER_NAME}



# Check if Elasticsearch pods are running

if kubectl get pods -n $NAMESPACE -l $ELASTICSEARCH_POD_LABEL | grep Running >/dev/null; then

    echo "All Elasticsearch pods are running."

else

    echo "One or more Elasticsearch pods are not running:"

    kubectl get pods -n $NAMESPACE -l $ELASTICSEARCH_POD_LABEL | grep -v Running

fi



# Check if Elasticsearch nodes are responsive

for POD in $(kubectl get pods -n $NAMESPACE -l $ELASTICSEARCH_POD_LABEL | grep Running | cut -f1 -d' '); do

    if kubectl exec -n $NAMESPACE $POD -c $ELASTICSEARCH_CONTAINER_NAME -- curl -s http://localhost:9200/_cluster/health | grep -q '\"status\":\"green\"'; then

        echo "$POD is responding."

    else

        echo "$POD is not responding:"

        kubectl logs -n $NAMESPACE $POD -c $ELASTICSEARCH_CONTAINER_NAME

    fi

done